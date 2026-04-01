#!/usr/bin/env bash
# Elasticsearch-Crawler
# NOTA: Elasticsearch-Crawler (AmIJesse) non e' piu' mantenuto.
# Le istanze Elasticsearch 8.x richiedono autenticazione di default,
# rendendo questo tool obsoleto per la maggior parte dei target.
# Considerare l'uso di Shodan CLI: https://cli.shodan.io/
# Compatibile con: Ubuntu 24.04 LTS, Ubuntu Budgie 24.04 LTS

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

zenity --warning \
    --title "Elasticsearch-Crawler — Tool Obsoleto" \
    --text "Elasticsearch-Crawler non e' piu' mantenuto.\n\nLe istanze Elasticsearch 8.x hanno autenticazione abilitata di default.\n\nAlternativa consigliata: Shodan CLI\n  pip install shodan\n  shodan search 'product:Elasticsearch'" \
    --width=450 \
    2> >(grep -v 'GtkDialog' >&2)
