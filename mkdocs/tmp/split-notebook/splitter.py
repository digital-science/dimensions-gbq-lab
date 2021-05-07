
#########
#
# split notebook .md file into multiple files based on string-pattern
#
# usage: 
# Export jupyter notebook to markdown 
# Run this script
# Use generated single md files
#
#########

# TIP Source File need to start with '# '
# 


def files():
    n = 0
    while True:
        n += 1
        yield open('output/%d.md' % n, 'w')


pat = '# '
fs = files()


with open("2-Publications-queries.md") as infile:
    for line in infile:
        if line.startswith(pat):
            outfile = next(fs) 
            print(line)
            outfile.write(line)
        else:
            outfile.write(line)
