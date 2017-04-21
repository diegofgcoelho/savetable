%This function transform a matrix in Matlab/Octave format into a TeX matrix.
%Usage:
%	save_table(matrix,file, varargin)
%
%Where matrix is a N by N matrix, with N any positive integer, file is a string
%with the name of the file you want the table to be saved in latex format and 
%varargin is a variable size argument as follows. 

%If varargin have size one, this argument can be a integer or an array of size 
%equals to the number of columns of the input matrix. If it is a integer, this 
%integer represents the number of significant digits. If it is an array, this 
%array components represent the number of significant digits for each of the 
%columns.

%If varargin have size two, the first argument is can be a intger, representing 
%the number of significant digits, or a vector representing the number of 
%significant digits for each column. The second argument is a vector with 1's 
%and 0's that must have the same size as the input matrix. If the kth component 
%in this vector is 1, the kth colmun quantities are rounded to integers (if the 
%difference between an integer and the actual value is smaller than precInt 
%variable) before 
%printing to the output file and is printed using scientifc notation in base 10 
%if the difference is greater than precInt.

%Examples:
%A = [1.0+(1e-25) 3.224e-5 5.477; 7-(1e-25) 3.1e-4 7.114];
%%to print using 2 significant digits
%save_table(A, 'matA.tex', 2);
%%to print using 2 significant digits where the first column is rounded to integers
%save_table(A, 'matA.tex', 2, [1 0 0]);
%%to print using 2, 3 and 1 significant digits for the 1st 2nd and 2rd columns
%save_table(A, 'matA.tex', [2 3 1]);
%%to print using 2, 3 and 1 significant digits for the 1st 2nd and 2rd columns
%%in scietific notation only the 1st and 2nd column
%save_table(A, 'matA.tex', [2 3 1], [1 1 0]);

%Change Log:
%Dec 25, 2013: Change the num2str call to mynum2str function, created in
%order to represent in tex appropriate form quantities in scientifc format.
%Jul 02, 2015: Add the vvariable s. If s==1, we use scientific notation,
%otherwise, we just round the quantities in the table.

%Diego F. Coelho
%diegofgcoelho@gmail.com
%Oct 04, 2012
%

function save_table(matrix,file, varargin);

[lin col] = size(matrix);

Ndigits = 2;
s = zeros([1 col]);;
if(~isempty(varargin))
    if(length(varargin) == 1)
        if(length(varargin{1}) == 1)
            s = ones([1 col]);
            %The number of siginificant digits all the same
            Ndigits = varargin{1}*ones([1 col]);
        elseif(length(varargin{1}) ~= 1)
            s = ones([1 col]);
            %Different number of siginificant digits for each column
            Ndigits = varargin{1};
            if(length(Ndigits) ~= col)
                fprintf('\n\nThe input array for the precision for each oclumn must agree with the input matrix.\n\n');
                return;
            end
        end
    elseif(length(varargin) == 2)
        Ndigits = varargin{1};
        s = varargin{2};
        if(length(s) ~= col)
            fprintf('\n\nThe input array for the format for each oclumn must agree with the input matrix.\n\n');
            return;
        end
    end
end

%Variable needed for rounding possible integer values. If you do not want
%If you do not want rouding, set this variable to zero.
precInt = 10^(-20);

%Openning the file and printing initial content in latex format
fileID = fopen(file,'w');
fprintf(fileID,'%s\n','\begin{table}');
fprintf(fileID,'%s\n','\begin{center}');
fprintf(fileID,'%s\n','\caption{put your caption here}');
fprintf(fileID,'%s\n','\label{put your label here}');
fprintf(fileID,'%s\n','\begin{tabular}{');

for k = 1:col
	fprintf(fileID,'%s','c');
end
fprintf(fileID,'%s\n','}');

%Initiate variables storing the value to be read from the matrix and the line
%to be written
valueToBeAdd = '';
lineToBeWritten = '';


%This loop runs over all the lines, printing one at a time
for k = 1:lin
  %This loop forms the string representing the current line to be written
	for n = 1:col
    if(abs(matrix(k,n)-round(matrix(k,n))) < precInt && s(n) == 1)
      valueToBeAdd = num2str(matrix(k,n));
    elseif(s(n) == 1)
      valueToBeAdd = mynum2str(Ndigits(n), matrix(k,n));
    elseif(s(n) ~= 1)
      valueToBeAdd = num2str(round(100*matrix(k,n))/100);
    end
    %valueToBeAdd = num2str(matrix(k,n));
    %If we have not reached the end of the line, we add $ to the left anf right
    %of the value to be added to the line. If it is the end of the line, we add
    %an end of line \\, which represent new line in latex. If it is the first
    %element, we add a space before the $ sign.
		if(n ~= col)
	    valueToBeAdd = strcat('$',valueToBeAdd,'$',' &');
		elseif(n == 1)
			valueToBeAdd = strcat(' ','$', valueToBeAdd,'$');
		else
			valueToBeAdd = strcat('$',valueToBeAdd,'$',' \\\midrule');
		end
  %Forms the final line to be written
  lineToBeWritten = strcat(lineToBeWritten, valueToBeAdd);
  end
  %Print the actual line in the file specified by fielID
	fprintf(fileID,'%s\n',lineToBeWritten);
  %Set the line to be written to empty again
	lineToBeWritten = '';
end
fprintf(fileID,'%s\n','\end{tabular}');
fprintf(fileID,'%s\n','\end{center}');
fprintf(fileID,'%s\n','\end{table}');
fclose('all');


function str = mynum2str(N, input)
%This function return a string whose content is the quantity in the input
%variable input argument in scientific notation with up to N siginificant
%digits.

%Author: Diego F. G. Coelho
%diegofgcoelho@gmail.com
%Dec 25, 2013
%It was produced as part of a research work with Prof. Dr. Cintra, Prof.
%Ph.D Dimitrov

%Change Log:

exp = 0;
for i = 1:30
    if(input*10^(i) >= 1)
        exp = i;
        break;
    end
end

%The value without the 10^exponent
num = round(input*10^(exp+N))/10^(N);
str = num2str(num);

%Including the 10^expoenent
str = strcat(str, '\cdot 10^{', num2str(-exp), '}');
