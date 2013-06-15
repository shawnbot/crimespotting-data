import optparse

parser = optparse.OptionParser()
parser.add_option('--config', '-C', dest='type_config', default="crime_types.json")
parser.add_option("--cat-key", "-c", dest="category_key", default="Category")
parser.add_option("--desc-key", "-d", dest="desc_key", default="Descript")
parser.add_option("--type-key", "-t", dest="type_key", default="type")
parser.add_option("--out", "-o", dest="output")
options, args = parser.parse_args()

import json, sys

fp = open(options.type_config, 'rU')
type_config = json.load(fp)
valid_types = type_config.get('valid')
type_mapping = type_config.get('mapping')
fp.close()

# print >> sys.stderr, 'valid types: %s' % valid_types
# print >> sys.stderr, 'type map: %s' % type_mapping

import csvkit

if len(args) == 0 or args[0] == '-':
    input_handle = sys.stdin
else:
    input_handle = open(args[0], 'rU')

if options.output:
    output_handle = open(options.output, 'w')
else:
    output_handle = sys.stdout

reader = csvkit.unicsv.UnicodeCSVDictReader(input_handle)
fields = reader.fieldnames
if not options.type_key in fields:
    fields.append(options.type_key)

writer = csvkit.unicsv.UnicodeCSVDictWriter(output_handle, fields)
writer.writeheader()

def fix_row(row):
    category = unicode(row.get(options.category_key, '')).upper()
    desc = unicode(row.get(options.desc_key, '')).upper()
    valid_type = None
    if category in valid_types:
        valid_type = category
    elif desc in valid_types:
        valid_type = desc
    elif type_mapping.has_key(category):
        valid_type = type_mapping.get(category)
    elif type_mapping.has_key(desc):
        valid_type = type_mapping.get(desc)
    print >> sys.stderr, 'category: %s, desc: %s, type: %s' % (category, desc, valid_type)
    row[options.type_key] = valid_type
    return row

for row in reader:
    fixed = fix_row(row)
    writer.writerow(fixed)

if output_handle is not sys.stdout:
    output_handle.close()
