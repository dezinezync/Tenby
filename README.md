# Tenby
Tenby is a simple JSON to CSV and CSV to JSON convertor. It's API has been designed to be simple and concise.  

Tenby exposes two kinds of APIs:  
- A file based API : responses are written to a temporary file and the file's URL is returned.
- An object based API : the processed object is directly returned.  
  
The File based API writes to a temporary location, and it's the user's job to move to a preferable location for long term storage.  

## API

    + (NSURL *)CSVFromJSON:(id)aObj;
    + (NSURL *)JSONFromCSV:(NSString *)csv;
    
    + (NSURL *)CSVFromJSON:(id)aObj delimiter:(NSString *)delimiter;
    + (NSURL *)JSONFromCSV:(NSString *)csv delimiter:(NSString *)delimiter;
    
    + (NSURL *)CSVFromJSON:(id)aObj delimiter:(NSString *)delimiter endOfLine:(NSString *)eol;
    + (NSURL *)JSONFromCSV:(NSString *)csv delimiter:(NSString *)delimiter endOfLine:(NSString *)eol;
    
    + (NSString *)CSVStringFromJSON:(id)aObj;
    + (NSArray *)JSONFromCSVString:(NSString *)csv;
    
    + (NSString *)CSVStringFromJSON:(id)aObj delimiter:(NSString *)delimiter;
    + (NSArray *)JSONFromCSVString:(NSString *)csv delimiter:(NSString *)delimiter;
    
    + (NSString *)CSVStringFromJSON:(id)aObj delimiter:(NSString *)delimiter endOfLine:(NSString *)eol;
    + (NSArray *)JSONFromCSVString:(NSString *)csv delimiter:(NSString *)delimiter endOfLine:(NSString *)eol;

All API methods have been documented inside the header file. 

Feel free to suggest new APIs or fork and send a pull request.

## TODO
- Read CSV and JSON objects from a file for processing.
- ~~Process multi-level JSON objects.~~
