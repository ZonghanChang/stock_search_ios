@outputSchema("word:chararray")
def split(line):
    res = ""
    for i in line:
		res = res + i + " "
    return res
