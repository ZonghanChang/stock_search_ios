register 'myfunc.py' using jython as myfunc;
lines = LOAD 'para\\d*.txt' AS (line:chararray);
splited = FOREACH lines GENERATE myfunc.split(line) AS splitline;
chars = FOREACH splited GENERATE FLATTEN(TOKENIZE(LOWER(splitline),' ')) as character;
grouped = GROUP chars BY character;
charCount = FOREACH grouped GENERATE group, COUNT(chars);
store charCount into 'charcount' USING PigStorage();

