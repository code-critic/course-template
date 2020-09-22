classdef check2
    %CHECK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'public', SetAccess = 'private')
        glob_tol
        msg_list
    end
    
    methods
        function obj = check2(tol)
            %CHECK Construct an instance of the 'check' class
            if tol <= 0
                obj.glob_tol = 1e-15;
            else
                obj.glob_tol = tol;
            end
            obj.msg_list = (struct( ...
                'msg',"", ...
                'stack', "", ...
                'code_line', "", ...
                'var_name', "", ...
                'note', "", ...
                'passed', 0));
        end
        
        function obj = expect_eq(obj, value, expected, varargin)
            % Checks equality of two objects 'value' and 'expected.
            % Checks the dimension.
            % Differentiates automaticallly between number and matrix.

            % variable name
            var_name = inputname(2);
            
            % optional note
            if length(varargin) == 1, note = string(varargin(1)); else, note = ""; end
            
            val_size = size(value);
            % dimension check
            if ~isequal(val_size, size(expected))
                msg = "EXPECT EQUAL: Dimension mismatch!";
                msg = sprintf("%s, value size: %s, expected size: %s", ...
                    msg, mat2str(val_size), mat2str(size(expected)));
                passed = 0;
            % scalar check
            elseif isequal(val_size, [1,1])
                % message
                msg =  sprintf("EXPECT EQUAL: value: %g, expected: %g", ...
                        value, expected);

                % test
                passed = value == expected;
            %matrix check
            else
                % message
                msg =  sprintf("EXPECT EQUAL matrix of size %s", ...
                        mat2str(val_size));

                % test
                passed = isequaln(value, expected);
            end
            
            % finalize
            obj = obj.expect_process(var_name, msg, passed, note);
        end
        
        function obj = expect_near(obj, value, expected, varargin)
            % Checks equality of two objects 'value' and 'expected
            % with some tolerance. Checks the dimension.
            % Differentiates automaticallly between number and matrix.
            % Relative tolerance can be given or the global one is used.
            
            % optional tolerance
            if ~isempty(varargin), tol = varargin{1}; else, tol = obj.glob_tol; end
            % optional note
            if length(varargin) > 1, note = string(varargin(2)); else, note = ""; end

            % variable name
            var_name = inputname(2);

            val_size = size(value);
            % dimension check
            if ~isequal(val_size, size(expected))
                msg = "EXPECT NEAR: Dimension mismatch!";
                msg = sprintf("%s, value size: %s, expected size: %s", ...
                    msg, mat2str(val_size), mat2str(size(expected)));
                passed = 0;
            % scalar check
            elseif isequal(val_size, [1,1])
                % message
                msg =  sprintf("EXPECT NEAR: value: %g, expected: %g, tolerance: %g", ...
                        value, expected, tol);

                % test
                passed = abs(value - expected) <= tol;
            %matrix check
            else
                % message
                msg =  sprintf("EXPECT NEAR matrix of size %s, rel. norm tolerance: %g", ...
                        mat2str(val_size), tol);

                % test
                rel_diff = norm(value - expected)/norm(expected);
                passed = rel_diff < tol;
            end
            
            % finalize
            obj = obj.expect_process(var_name, msg, passed, note);
        end
        
        function obj = expect_lt(obj, value, expected, varargin)
            % Checks whether 'value' < 'expected.
            % Checks the dimension.

            % optional note
            if length(varargin) == 1, note = string(varargin(1)); else, note = ""; end
            
            % variable name
            var_name = sprintf("%s, %s", inputname(2), inputname(3));
            
            val_size = size(value);
            % dimension check and scalar check
            if ~isequal(val_size, size(expected)) && isequal(val_size, [1,1])
            
                msg = "EXPECT EQUAL: Dimension mismatch, numbers expected!";
                msg = sprintf("%s, value size: %s, expected size: %s", ...
                    msg, mat2str(val_size), mat2str(size(expected)));
                passed = 0;
            % scalar check
            else 
                % message
                msg =  sprintf("EXPECT LT: value: %g < expected: %g", ...
                        value, expected);

                % test
                passed = value < expected;
            end
            
            % finalize
            obj = obj.expect_process(var_name, msg, passed, note);
        end
        
        function finalize(obj)
            % Finalize the check procedure.
            % Evalutate the collected test results, print report.
            
            fprintf("==================================================\n")
            obj.print_all();
            fprintf("--------------------------------------------------\n")
            passed = obj.evaluation();
            fprintf("==================================================\n")
            
            if ~passed
                error("Some of the tests failed!")
            end
        end
        
        function print_all(obj)
            % Print the list of all collected test reports.
            n = length(obj.msg_list);
            for i=2:n
                s = obj.msg_list(i);
                if s.passed
                    fprintf("[PASSED]:\n")
                else
                    fprintf("[FAILED]:\n")
                end
                fprintf("Message: %s\n", s.msg);
                fprintf("Variable: %s\n", s.var_name);
                fprintf("Expression: %s\n", s.code_line);
                if s.note ~= ""
                    fprintf("Note: %s\n", s.note);
                end
                if ~s.passed
                    fprintf("Stack:\n%s\n", s.stack);
                else
                    fprintf("\n");
                end
            end
        end
        
        function passed = evaluation(obj)
            % Go through all the collected tests, count passed tests
            % and evaluate final result passed/failed.
            
            n = length(obj.msg_list);
            n_passed = 0;
            n_total = n-1;
            for i=2:n
                s = obj.msg_list(i);
                if s.passed
                    n_passed = n_passed + 1;
                end
            end
            
            fprintf("[SUMMARY]:\n %d / %d tests passed succesfully.\n", ...
                n_passed, n_total);
            
            passed = n_passed == n_total;
        end
    end
    
    methods (Access = private)
        function obj = expect_process(obj, var_name, msg, passed, note)
            % Creates the final structure with information about the check.
            
            % stack and code_line
            [st_msg, code_line] = obj.get_call_stack(2);
            
            % save all
            s.stack = st_msg;
            s.code_line = code_line;
            s.var_name = var_name;
            s.msg = msg;
            s.passed = passed;
            s.note = note;
            obj.msg_list(end+1) = s;

        end
        
        function [stack_string, code_line] = get_call_stack(~, N)
            % Gets a string describing the call stack.
            % Each line includes a filename, a function name, and line number.
            % N is number of skipped calls.
            try
                [st, ~] = dbstack('-completenames', N);
                stack_string = "";
                for k = 1 : length(st)
                    [~, fn, ext] = fileparts(st(k).file);
                    filename = strcat(fn,ext);
                    stack_string = stack_string + ...
                        sprintf("%d: File: '%s', function '%s()' at line %d.\n", ...
                            k, filename, st(k).name, st(k).line);
                end
                
                % find the code
                fid=fopen(st(2).file); 
                % set linenum to the desired line number that you want to import
                linenum = st(2).line;
                % use '%s' if you want to read in the entire line or use '%f' if you want to read only the first numeric value
                cell = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
                code_line = string(cell);
                
            catch ME
                stack_string = "";
                code_line = "";
                errorMessage = sprintf('Error in Program Check %s.\nError Message:\n%s', ...
                    mfilename, ME.message);
                warning(errorMessage);
            end
            
            %             try
%                 assert(value == expected)
%             catch ME
%                 s.stack = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
%                     ME.stack(2).name, ME.stack(2).line, ME.message);
% 
%                 s.msg = sprintf("EXPECT EQUAL: value: %g, expected: %g\n", value, expected);
%                 obj.msg_list(end+1) = s;
%             end       
        end
    end
end

