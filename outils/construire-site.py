#!/usr/bin/env python3
"""
Construit le site de la formation (un seul fichier HTML autonome) à partir de :
  - l'export Markdown du document de formation (menu du document : Exporter > Markdown) ;
  - la banque de questions qcm/qcm-facturo.json ;
  - le modèle outils/site/modele.html.

Usage (depuis la racine du dépôt) :
    python3 outils/construire-site.py --formation ../support/formation.md
Options : --qcm, --modele, --sortie (par défaut site/index.html).

Les sections réservées au formateur (QCM rédigés, corrigé, guide enseignant) ne sont pas publiées :
le site affiche les QCM à partir de la banque de questions.
Bibliothèque standard uniquement : aucune dépendance à installer.
"""
import argparse
import json
import pathlib
import re
import sys
import unicodedata
from datetime import datetime, timezone

RACINE = pathlib.Path(__file__).resolve().parent.parent
EXCLUES = ("qcm", "corrigé", "corrige", "guide enseignant")


def slug(texte):
    t = unicodedata.normalize("NFKD", texte).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "-", t).strip("-")[:40] or "section"


def decouper(md):
    """Retourne (titre, [(titre_section, lignes)]) en ignorant les '## ' dans les blocs de code."""
    lignes = md.replace("\r\n", "\n").split("\n")
    titre, sections, courant, dans_code = "Formation", [], None, False
    for i, ligne in enumerate(lignes):
        if ligne.strip().startswith("```"):
            dans_code = not dans_code
        if not dans_code and ligne.startswith("# ") and titre == "Formation":
            titre = ligne[2:].strip()
            continue
        if not dans_code and ligne.startswith("## "):
            courant = [ligne[3:].strip(), [ligne]]
            sections.append(courant)
            continue
        if courant is not None:
            courant[1].append(ligne)
    return titre, sections


def decrire(titre_section):
    """Identifiant, numéro affiché, libellé court, clé QCM et parent d'une section."""
    court = titre_section.split(" — ", 1)[1] if " — " in titre_section else titre_section
    court = re.sub(r"\s*\([^)]*\)\s*$", "", court)   # « Penser en base (6 séances, 8 h) » -> « Penser en base »
    m = re.match(r"^Module (\d+)\b", titre_section)
    if m:
        n = m.group(1)
        return {"id": "m" + n, "num": n, "court": court, "qcm": None if n == "5" else n, "parent": None}
    m = re.match(r"^(\d+)\.(\d+)\b", titre_section)
    if m:
        a, b = m.groups()
        return {"id": "m%s-%s" % (a, b), "num": "%s.%s" % (a, b), "court": court, "qcm": "%s.%s" % (a, b), "parent": "m" + a}
    if titre_section.lower().startswith("pièges"):
        return {"id": "pieges", "num": "", "court": "Pièges courants", "qcm": None, "parent": None}
    return {"id": slug(titre_section), "num": "", "court": court, "qcm": None, "parent": None}


def nettoyer(lignes):
    texte = "\n".join(lignes)
    # le schéma interactif du document est exporté comme un simple libellé : on le remplace par l'arbre cliquable
    texte = re.sub(r"^.*embedded content:\s*Arbre de d[ée]cision.*$", '<div class="arbre" data-arbre></div>', texte, flags=re.M | re.I)
    return texte.strip() + "\n"


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--formation", required=True, help="export Markdown du document de formation")
    p.add_argument("--qcm", default=str(RACINE / "qcm" / "qcm-facturo.json"))
    p.add_argument("--modele", default=str(RACINE / "outils" / "site" / "modele.html"))
    p.add_argument("--sortie", default=str(RACINE / "site" / "index.html"))
    a = p.parse_args()

    source = pathlib.Path(a.formation)
    if not source.is_file():
        sys.exit("Fichier introuvable : %s\nExportez le document de formation en Markdown et indiquez son chemin." % source)
    titre, brutes = decouper(source.read_text(encoding="utf-8"))
    sections, ids = [], set()
    for titre_section, lignes in brutes:
        if titre_section.lower().startswith(EXCLUES):
            continue
        d = decrire(titre_section)
        while d["id"] in ids:
            d["id"] += "-bis"
        ids.add(d["id"])
        d["md"] = nettoyer(lignes)
        sections.append(d)
    if not sections:
        sys.exit("Aucune section « ## » trouvée dans %s : est-ce bien l'export Markdown du document ?" % source)

    qcm = json.loads(pathlib.Path(a.qcm).read_text(encoding="utf-8"))
    cles = {s["qcm"] for s in sections if s["qcm"]}
    sans_questions = sorted(k for k in cles if not any(q["module"] == k for q in qcm["questions"]))
    donnees = {"titre": titre, "construit": datetime.now(timezone.utc).isoformat(timespec="seconds"),
               "sections": sections, "qcm": qcm}
    json_txt = json.dumps(donnees, ensure_ascii=False).replace("</", "<\\/")
    modele = pathlib.Path(a.modele).read_text(encoding="utf-8")
    if "__DONNEES__" not in modele:
        sys.exit("Le modèle ne contient pas le marqueur __DONNEES__.")
    sortie = pathlib.Path(a.sortie)
    sortie.parent.mkdir(parents=True, exist_ok=True)
    sortie.write_text(modele.replace("__DONNEES__", json_txt), encoding="utf-8")

    print("Site écrit dans %s (%d Ko)" % (sortie, sortie.stat().st_size // 1024))
    print("  %d sections publiées : %s" % (len(sections), ", ".join(s["id"] for s in sections)))
    print("  %d questions" % len(qcm["questions"]))
    if sans_questions:
        print("  attention : aucune question pour %s" % ", ".join(sans_questions))


if __name__ == "__main__":
    main()
