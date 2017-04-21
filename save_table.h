#include <cstdio>
#include <iostream>
#include <cstring>

void save_table(char const* filename, double** table, unsigned size1, unsigned size2, char const* format, bool latex){
	/*Input:
	 * filename is a char representing the name of the file to be save
	 * table is the pointer to the table to be saved--pointer to pointer of doubles
	 * size1 and size2 represents the number of rows and columns of the input argument table
	 * format is a array of chars representing the format that the table must be printed
	 * separetor is the type of separation between the table entries to be printed. If you are using latex format,
	 * this variable value is discarded
	 * latex is a bool representing if the user want the table to be print in latex format or not
	 */
	/*Output:
	 * void, but the function creates the file with filename and print the table in it
	 */
	/*
	 * Requirement:
	 * filename must be a valid name for a file and have no blank space and must be not exist--unless intentionally
	 * you want overwrite them
	 */
	/*Description:
	 * the file with name filename is created and the table have either normal text or late format. The precision in the
	 * double quantities is determined by the input argument format.
	 * Example 1:
	 * You want print a table with 4 rows and 3 columns where the last column must be printed as integer and the
	 * first two columns as doubles. The first table must be in scientific notation with 3 decimal points and the second
	 * in normal representation with 2 decimal points. The elements must be separated by tab and you want normal text format.
	 * Then you call:
	 * save_table("myfilname.txt", table, 4, 3, "%.3e%.4f%d", "\t", false);
	 *
	 * Example 2:
	 * You want print a 5x10 table where all the columns are float points with 3 decimals and only the first column must
	 * be in integer format and you want it to be in latex format. You can do:
	 * save_table("myfilname.txt", table, 5, 10, "%d%.3f%.3f%.3f%.3f%.3f%.3f%.3f%.3f%.3f", " ", true);
	 */

	//Sanity Check
	FILE* filep = std::fopen(filename, "w");
	if(filep == NULL){
		printf("\n\nProblem opening the file. Leaving function.\n\n");
		return;
	}

	//Converting the input array of char to string
	std::string filename_string = std::string(filename);
	//Converting the input array of char to string
	std::string format_string = std::string(format);
	//Converting the input array of char to string
	std::string tempformat_string = std::string();
	//Auxiliary variables for printing
	char tempformat[7];
	int pos = 0;

	if (latex==false) {
		printf("\n\nPriting data in text format.\n\n");
		//Part for printing in text format
		for(unsigned i = 0; i < size1; i++){
			//Resetting pos variable
			pos = 0;
			for(unsigned j = 0; j < size2; j++){
				int fpos = format_string.find("%", pos+1);
				//Checking if it is the last element in the column
				if(fpos < 0){
					//Copying the content in the format string to the temporary string to print
					format_string.copy(tempformat, format_string.length()-pos, pos);
					//Setting the end of the string for this particular element format
					tempformat[format_string.length()-pos+1] = '\0';
					//Print the element that is the last one in the column
					fprintf(filep, tempformat, table[i][j]);
				}else{
					//Copying the content in the format string to the temporary string to print
					tempformat_string = format_string.substr(pos, fpos-pos)+"\t";
					tempformat_string.copy(tempformat, tempformat_string.length(), 0);
					tempformat[tempformat_string.length()] = '\0';
					//Update the position for the next element to be print
					pos = fpos;
					//Print the element
					fprintf(filep, tempformat, table[i][j]);
				}
			}
			fprintf(filep, "\n");
		}
	} else {
		printf("\n\nPriting data in latex format.\n\n");
		//Printing in the latex format
		fprintf(filep,"%% add the booktabs package in the main latex file\n");
		fprintf(filep,"\\begin{table}\n");
		fprintf(filep,"\\begin{center}\n");
		fprintf(filep,"\\caption{write your caption here}\n");
		fprintf(filep,"\\label{write your label here}\n");
		fprintf(filep,"\\begin{tabular}{\n");


		for(unsigned i = 0; i < size1; i++){
				//Resetting pos variable
				pos = 0;
				for(unsigned j = 0; j < size2; j++){
					int fpos = format_string.find("%", pos+1);
					//Checking if it is the last element in the column
					if(fpos < 0){
						//Copying the content in the format string to the temporary string to print
						format_string.copy(tempformat, format_string.length()-pos, pos);
						//Setting the end of the string for this particular element format
						tempformat[format_string.length()-pos+1] = '\0';
						//Print the element that is the last one in the column
						fprintf(filep, "$");
						fprintf(filep, tempformat, table[i][j]);
						fprintf(filep, "$");
					}else{
						//Copying the content in the format string to the temporary string to print
						tempformat_string = format_string.substr(pos, fpos-pos)+"\t";
						tempformat_string.copy(tempformat, tempformat_string.length(), 0);
						tempformat[tempformat_string.length()] = '\0';
						//Update the position for the next element to be print
						pos = fpos;
						//Print the element
						fprintf(filep, "$");
						fprintf(filep, tempformat, table[i][j]);
						fprintf(filep, "$ &");
					}
				}
				fprintf(filep, "\\\\\\midrule\n");
			}

		fprintf(filep,"\\end{tabular}\n");
		fprintf(filep,"\\end{center}\n");
		fprintf(filep,"\\end{table}\n");
	}
	//Closing the file opened for writing the table content
	fclose(filep);
}
