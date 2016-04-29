register 'myfunc.py' using jython as myfunc;
lines = LOAD 'para\\d*.txt' AS (line:chararray);
splited = FOREACH lines GENERATE myfunc.split(line) AS splitline;
chars = FOREACH splited GENERATE FLATTEN(TOKENIZE(LOWER(splitline))) as character;
letters = FILTER chars BY character MATCHES '[aeiou]';
grouped = GROUP letters BY character;
letterCount = FOREACH grouped GENERATE group, COUNT(letters);
store letterCount into 'lettercount' USING PigStorage();

