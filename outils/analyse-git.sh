#!/usr/bin/env bash
# =====================================================================
# Analyse de l'historique Git des rendus : un tableau par branche <login>/exNN-*.
#
# Usage   : ./outils/analyse-git.sh [--fetch] [--csv fichier.csv] [motif-login]
# Exemple : ./outils/analyse-git.sh --fetch --csv rapport.csv
#           ./outils/analyse-git.sh jdupont
#
# Base de comparaison d'une branche exNN : la branche d'exercice précédente la plus proche
# du même stagiaire, sinon origin/main (ou main). Les commits de fusion sont ignorés.
# Les indicateurs sont des INDICES pour la relecture, pas une note.
# =====================================================================
set -uo pipefail

FETCH=0; CSV=""; FILTRE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --fetch) FETCH=1 ;;
    --csv) CSV="$2"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) FILTRE="$1" ;;
  esac
  shift
done

cd "$(git rev-parse --show-toplevel)" || exit 1
[ "$FETCH" = 1 ] && git fetch --all --prune --quiet

if git rev-parse -q --verify origin/main >/dev/null; then MAIN=origin/main; else MAIN=main; fi
RE_MSG='^(feat|fix|refactor|test|docs|chore|style|perf|build)\((ex0[1-8]|base)\): .{10,72}$'
SEUIL_GROS=300

# Branches : distantes si présentes, sinon locales ; une seule entrée par nom
branches=$( { git for-each-ref --format='%(refname:short)' refs/remotes/origin | sed -n 's#^origin/##p';
              git for-each-ref --format='%(refname:short)' refs/heads; } \
            | grep -E '^[a-z0-9._-]+/ex0[1-8]([-_].*)?$' | sort -u )
[ -n "$FILTRE" ] && branches=$(echo "$branches" | grep -E "^${FILTRE}" || true)
[ -z "$branches" ] && { echo "Aucune branche <login>/exNN-* trouvée."; exit 0; }

ref_de() { if git rev-parse -q --verify "origin/$1" >/dev/null; then echo "origin/$1"; else echo "$1"; fi; }

entete="login|ex|commits|msg conformes|avec corps|Assisted-by|lignes +/-|plus gros commit|commits >${SEUIL_GROS}|jours|dernières 24 h|RENDU|JOURNAL_IA|alertes"
[ -n "$CSV" ] && echo "$entete" | tr '|' ';' > "$CSV"
echo "| ${entete//|/ | } |"
echo "|$(echo "$entete" | sed 's/[^|]*/ --- /g')|"

for b in $branches; do
  login=${b%%/*}; ex=$(echo "$b" | grep -oE 'ex0[1-8]'); n=${ex#ex0}
  ref=$(ref_de "$b")
  base=$MAIN
  for ((k=n-1; k>=1; k--)); do        # exercice précédent le plus proche qui existe
    prec=$(echo "$branches" | grep -E "^${login}/ex0${k}([-_]|$)" | head -n1)
    if [ -n "$prec" ]; then base=$(ref_de "$prec"); break; fi
  done
  mb=$(git merge-base "$base" "$ref" 2>/dev/null) || mb=$base
  commits=$(git rev-list --no-merges --reverse "$mb..$ref")
  nb=$(echo "$commits" | grep -c . || true)
  if [ "$nb" -eq 0 ]; then
    ligne="$login|$ex|0|-|-|-|-|-|-|-|-|-|-|aucun commit propre à la branche"
  else
    conf=0; corps=0; ia=0; gros=0; max=0; plus=0; moins=0; recents=0
    dernier=$(git log -1 --format=%ct "$ref")
    jours=$(git log --no-merges --format=%cd --date=format:%Y-%m-%d "$mb..$ref" | sort -u | wc -l)
    for c in $commits; do
      sujet=$(git log -1 --format=%s "$c")
      [[ "$sujet" =~ $RE_MSG ]] && conf=$((conf+1))
      nl=$(git log -1 --format=%b "$c" | grep -v -iE '^(Assisted-by|Co-authored-by|Signed-off-by):' | grep -c '[^[:space:]]' || true)
      [ "$nl" -gt 0 ] && corps=$((corps+1))
      git log -1 --format=%B "$c" | grep -qiE '^Assisted-by:' && ia=$((ia+1))
      read -r a d < <(git show --numstat --format= "$c" | awk '$1!="-"{a+=$1; d+=$2} END{print a+0, d+0}')
      plus=$((plus+a)); moins=$((moins+d)); t=$((a+d))
      [ "$t" -gt "$max" ] && max=$t
      [ "$t" -gt "$SEUIL_GROS" ] && gros=$((gros+1))
      [ $((dernier - $(git log -1 --format=%ct "$c"))) -le 86400 ] && recents=$((recents+1))
    done
    rendu=non; journal="-"
    git cat-file -e "$ref:rendus/$login/$ex/RENDU.md" 2>/dev/null && rendu=oui
    if [ "$n" -ge 5 ]; then journal=non; git cat-file -e "$ref:rendus/$login/$ex/JOURNAL_IA.md" 2>/dev/null && journal=oui; fi
    alertes=""
    [ "$nb" -lt 5 ] && alertes+="moins de 5 commits; "
    [ $((conf*100/nb)) -lt 80 ] && alertes+="messages non conformes; "
    [ "$gros" -gt 0 ] && alertes+="commit(s) > ${SEUIL_GROS} lignes; "
    [ "$nb" -ge 5 ] && [ $((recents*100/nb)) -ge 80 ] && [ "$jours" -le 1 ] && alertes+="travail concentré sur 24 h; "
    [ "$rendu" = non ] && alertes+="RENDU absent; "
    [ "$journal" = non ] && alertes+="JOURNAL_IA absent; "
    [ "$n" -le 4 ] && [ "$ia" -gt 0 ] && alertes+="Assisted-by en partie sans IA (vérifier la déclaration); "
    [ "$n" -ge 5 ] && [ "$ia" -eq 0 ] && alertes+="aucun Assisted-by en partie avec IA; "
    ligne="$login|$ex|$nb|$((conf*100/nb)) %|$((corps*100/nb)) %|$ia|+$plus / -$moins|$max|$gros|$jours|$((recents*100/nb)) %|$rendu|$journal|${alertes%; }"
  fi
  echo "| ${ligne//|/ | } |"
  [ -n "$CSV" ] && echo "$ligne" | tr '|' ';' >> "$CSV"
done
[ -n "$CSV" ] && echo && echo "CSV écrit dans $CSV"
