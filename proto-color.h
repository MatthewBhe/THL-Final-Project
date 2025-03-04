/* Shortlist of ANSI-VT100 Escape Sequence         */
/* cf. Palettes/palette-*.h pour versions etendues */

#define ATT_RST  "\x1B[0m"  /* = [0m Reset [0m */
#define ATT_BOLD "\x1B[1m"  /* = [1m BOLD  [0m */
#define ATT_UND  "\x1B[4m"  /* = [4m UNDERLINE [0m */
#define ATT_REV  "\x1B[7m"  /* = [7m REVERSE [0m */
#define ATT_FG1  "\x1B[31m" /* = [31m RED [0m */
#define ATT_FG2  "\x1B[32m" /* = [32m GREEN [0m */
#define ATT_FG4  "\x1B[34m" /* = [34m BLUE [0m */

/* Macro cpp pour Colorer une chaine  */
/* ex : printf( RED("[ %s ]") , str); */
/* ex : printf( GREEN("%s")" / "RED("%s") , str1, str2);  */

#define GREEN(str) ATT_FG2 str ATT_RST
#define RED(str)   ATT_FG1 str ATT_RST
#define BLUE(str)  ATT_FG4 str ATT_RST
#define REV(str)   ATT_REV str ATT_RST

/* Fonction pour changer la couleur de stdout   */
/* SET_COLOR(0) reset a la couleur par defaut   */
/* SET_COLOR(i) passe a la couleur i (modulo N) */

#include <stdio.h>
static int color_map_size = 6;
static char *color_map[] = {
  /* Green, Red, Blue, Rev_Green, Rev_Red, Rev Blue */
    ATT_FG2, ATT_FG1 , ATT_FG4 , 
    ATT_REV ATT_FG2, ATT_REV ATT_FG1 , ATT_REV ATT_FG4 
} ;  

static __attribute__((unused)) void SET_COLOR (int i) {
  printf("%s",ATT_RST);
  if (i!=0) printf("%s",color_map[(i-1)%color_map_size]);
}
