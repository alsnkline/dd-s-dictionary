#ifndef DOUBLE_METAPHONE__H
#define DOUBLE_METAPHONE__H


typedef struct
{
    char *str;
    int length;
    int bufsize;
    int free_string_on_destroy;
}
metastring;      


#ifdef __cplusplus  //putting extern "C" declaration of the method so it can be called by Obj C classes http://stackoverflow.com/questions/4456239/calling-c-method-from-objective-c
extern "C" {
#endif

void
DoubleMetaphone(const char *str,
                char **primarycode, char **secondarycode);

#ifdef __cplusplus
}
#endif
    
#endif /* DOUBLE_METAPHONE__H */
