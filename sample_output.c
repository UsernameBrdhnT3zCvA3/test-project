/* Generated C Table from Excel Data */
/* Columns: A, B, C */

#include <stdio.h>

typedef struct {
    const char* col_a;
    const char* col_b;
    const char* col_c;
} TableRow;

TableRow data_table[] = {
    {"田中太郎", "25", "東京"},
    {"佐藤花子", "30", "大阪"},
    {"鈴木一郎", "28", "名古屋"},
    {"高橋美咲", "35", "福岡"},
    {"伊藤健太", "22", "札幌"}
};

#define TABLE_SIZE (sizeof(data_table) / sizeof(data_table[0]))

/* Sample function to print table data */
void print_table() {
    int i;
    printf("Table Data (%d rows):\n", TABLE_SIZE);
    printf("%-20s %-20s %-20s\n", "Column A", "Column B", "Column C");
    printf("------------------------------------------------------------------------\n");
    for (i = 0; i < TABLE_SIZE; i++) {
        printf("%-20s %-20s %-20s\n",
               data_table[i].col_a ? data_table[i].col_a : "(null)",
               data_table[i].col_b ? data_table[i].col_b : "(null)",
               data_table[i].col_c ? data_table[i].col_c : "(null)");
    }
}

/* Main function for testing */
int main() {
    printf("=== Excel to C Table Converter Sample ===\n\n");
    
    print_table();
    
    printf("\n=== Individual access example ===\n");
    printf("First row: %s, %s, %s\n", 
           data_table[0].col_a, 
           data_table[0].col_b, 
           data_table[0].col_c);
    
    printf("Last row: %s, %s, %s\n", 
           data_table[TABLE_SIZE-1].col_a, 
           data_table[TABLE_SIZE-1].col_b, 
           data_table[TABLE_SIZE-1].col_c);
    
    return 0;
}