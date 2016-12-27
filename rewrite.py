import codecs
import os
import re

f = open('new-list')
lines = f.readlines()
f.close()

tm = {}
for line in lines:
    (new, old) = line.split('@')
    tm[old.strip()] = new.strip()

assert len(tm) == 848

rx = re.compile(r'(.+)/c/20..-..-../s1920/(.*\....)')
for dirpath, _, filenames in os.walk('/Users/yacoob/workarea/gcu/kits', followlinks=True):
    for filename in filenames:
        if not filename.endswith('.yaml'):
            continue
        fp = os.path.join(dirpath, filename)
        print 'processing file: %s' % fp
        f = codecs.open(fp, 'r', 'utf-8')
        lines = f.readlines()
        f.close()
        f = codecs.open(fp, 'w', 'utf-8')
        for line in lines:
            line = line.rstrip()
            m = rx.search(line)
            if m:
                assert len(m.groups()) == 2
                of = m.group(2)
                assert tm.has_key(of), of
                nf = tm[of]
                line = m.group(1) + '/f/full/' + nf + '.jpg'
            f.write('%s\n' % line)
        f.close()
