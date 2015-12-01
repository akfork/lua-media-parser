
local meta_table = require('meta_table')

meta_table.mp4_meta_table('mpeg4conformance.mp4')

r = meta_table.get_meta_table()

print(r)
