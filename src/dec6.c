#include <stdio.h>

#define ALPHABET_START ('a')
#define ALPHABET_END ('z')
#define ALPHABET_LENGTH (ALPHABET_END - ALPHABET_START + 1)

#define CMP(a, b, strategy) (((a) * (strategy)) > ((b) * (strategy)))

int main(int argc, char *argv[]) {
	FILE *file = fopen("input.txt", "r");
		
	// count the number of columns
	const int column_count = ({
		int c; int count = -1;
		do { c = fgetc(file); count += 1; }
		while (c != EOF && (char)c != '\n');
		count;
	});
	
	// for both the max occurance and min occurance strategy
	for (int strategy = 1; strategy >= -1; strategy -= 2) {
		
		// for each column
		for (int column = 0; column < column_count; column++) {
			// just back to start for this column
			fseek(file, column, SEEK_SET);
			
			// record the number of occurances each char
			int counts[ALPHABET_LENGTH] = { 0 };
			{
				int c;
				while ((c = fgetc(file)) != EOF) {
					const int i = (int)(c - ALPHABET_START);
					counts[i] += 1;
					fseek(file, column_count, SEEK_CUR);
				}
			}
			
			// find the char that had the most or least occurances
			int best_i = 0;
			int best_count = counts[0];
			for (int i = 1; i < ALPHABET_LENGTH; i++) {
				const int count = counts[i];
				if (CMP(count, best_count, strategy)) {
					best_count = count;
					best_i = i;
				}
			}
			printf("%c", (char)(best_i + ALPHABET_START));
		}
		printf("\n");
	}
}