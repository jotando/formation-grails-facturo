#!/usr/bin/env python3
"""Génère qcm/qcm-facturo.gift (import Moodle) à partir de qcm/qcm-facturo.json, la source unique des questions.
Usage : python3 outils/qcm_vers_gift.py"""
import json, pathlib
racine = pathlib.Path(__file__).resolve().parent.parent
data = json.loads((racine / "qcm" / "qcm-facturo.json").read_text(encoding="utf-8"))

def esc(t):  # caractères réservés du format GIFT
    for c in "\\~=#{}:":
        t = t.replace(c, "\\" + c)
    return t

lignes = [f"// {data['titre']} — généré depuis qcm-facturo.json, ne pas éditer à la main", ""]
courant = None
for q in data["questions"]:
    if q["module"] != courant:
        courant = q["module"]
        lignes += [f"$CATEGORY: $course$/Facturo/{esc(data['modules'][courant])}", ""]
    lignes.append(f"::{q['id']}::[markdown]{esc(q['question'])} {{")
    for o in q["options"]:
        lignes.append(f"\t{'=' if o['correcte'] else '~'}{esc(o['texte'])}")
    lignes.append(f"\t####{esc(q['justification'])}")
    lignes += ["}", ""]
(racine / "qcm" / "qcm-facturo.gift").write_text("\n".join(lignes), encoding="utf-8")
print(f"{len(data['questions'])} questions écrites dans qcm/qcm-facturo.gift")
