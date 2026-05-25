import json
import os

# Run: python tools/gen_arb.py
strings = {}  # populated below in file - use exec from separate data file

exec(open(os.path.join(os.path.dirname(__file__), 'arb_strings.py'), encoding='utf-8').read())

def placeholders(key, es):
    ph = {}
    if '{error}' in es:
        ph['error'] = {'type': 'String'}
    if '{name}' in es:
        ph['name'] = {'type': 'String'}
    if '{query}' in es:
        ph['query'] = {'type': 'String'}
    if '{date}' in es:
        ph['date'] = {'type': 'String'}
    if '{km}' in es:
        ph['km'] = {'type': 'String'}
    if '{minutes}' in es:
        ph['minutes'] = {'type': 'int'}
    if '{hours}' in es:
        ph['hours'] = {'type': 'int'}
    if 'count, plural' in es or '{count}' in es:
        ph['count'] = {'type': 'int'}
    return ph

es_arb = {'@@locale': 'es'}
en_arb = {'@@locale': 'en'}
for key, (es, en) in strings.items():
    es_arb[key] = es
    en_arb[key] = en
    ph = placeholders(key, es)
    if ph:
        es_arb['@' + key] = {'placeholders': ph}
        en_arb['@' + key] = {'placeholders': ph}

root = os.path.dirname(os.path.dirname(__file__))
l10n_dir = os.path.join(root, 'lib', 'l10n')
os.makedirs(l10n_dir, exist_ok=True)
with open(os.path.join(l10n_dir, 'app_es.arb'), 'w', encoding='utf-8') as f:
    json.dump(es_arb, f, ensure_ascii=False, indent=2)
with open(os.path.join(l10n_dir, 'app_en.arb'), 'w', encoding='utf-8') as f:
    json.dump(en_arb, f, ensure_ascii=False, indent=2)
print('ARB files written', len(strings), 'keys')
