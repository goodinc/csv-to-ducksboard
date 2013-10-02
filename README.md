#### CSV-to-Ducksboard
This script lets you upload data from CSV/TSV files to a [Ducksboard](http://ducksboard.com) widget

#### Usage
    ~/code/csv-to-ducksboard $ cat test.csv 

      Date,Bugs
      2012-07-03,7
      2012-07-04,6
      2012-07-05,10
      2012-07-06,8
      2012-07-07,4
    
    ~/code/csv-to-ducksboard $ ./csv-to-ducksboard.rb --api-key <API KEY> --widget-id 64590 \
                                                      --column datetime --column value \
                                                      --num-header-rows 1 \
                                                      --tsv test.csv

#### To Do
- All input from stdin
- Make it a gem
- Use stderr/stdout as appropriate
- Return error return values
