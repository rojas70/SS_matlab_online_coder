%% ************************** Documentation *********************************
% Write to file, statistical data used in fitRegressionCurves to analyze 
% segmented portions of force-moment data.
%
% Update for RT Online Generation.
% Fixed folder located at: '/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp'
%
% Input Variables:
% Path              : path string to the "Results" directory
% StratTypeFolder   : path string to Position/Force Control and Straight Line
%                     approach or Pivot Approach.
% Foldername        : name of folder of data we are handling
% Type              : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz
% segmentIndex      : index of segmented block number
% dAvg              : mean value of data
% dMax              : max value of data
% dMin              : min value of data
% dStart            : starting time value of current segmented block
% dFinish           : finishing time value of current segmented block
% dGradient         : gradient of fitted curve for segmented block
% dLabel            : integer gradient label indicating whether big+/-, moderate
%                     +/-, or small +/-. it's an int.
%
% Modifications:
% July 2012 - to facilitate the conversion from Matlab to C++ all cells
% have been eliminated. String2Int and Int2String conversions are done when
% necessary to avoid the use of cells. 
% We write to file data with string labels to make it easier to read. 
%----------------------------------------------------------------------------------------------------------
function [write2FileFlag]=WritePrimitivesToFile(~,~,~,...
                                               Type,write2FileFlag,...
                                               segmentIndex,dAvg,dMax,dMin,dStart,dFinish,dGradient,dLabel)
%% Globals
    %global segmentDirectoryFlag;
    %global segmentDir;
                                           
%% Create Directory
%% Online RT Assume Directory is created.
%     if(ispc)
%     if(segmentDirectoryFlag)
%         % Set path with new folder "Segments" in it.
%         SegmentFolder='Segments';
%         segmentDir  = strcat(WinPath,StratTypeFolder,FolderName,'\\',SegmentFolder);        
% 
%         segmentDir  = '/home/vmrguser/src/OpenHRP-3.0/src/Controller/IOServer/HRP2STEP1/bin/tmp/Segments';  
%         % Check if directory exists, if not create a directory
%         if(exist(segmentDir,'dir')==7)
%             mkdir(dir);
%         end
% 
%         % Change the global flag to false so we don't do this again
%         segmentDirectoryFlag=false;
%     end          

%     % Linux
%     else
%         if(segmentDirectoryFlag)        
%             SegmentFolder='Segments';
%             LinuxPath   = '\\home\\Documents\\Results\\Force Control\\Pivot Approach\\';
%             %Path    =
%             %'\\home\\hrpuser\\forceSensorPlugin_Pivot\\data\\Results\\'
%             segmentDir        = strcat(LinuxPath,StratTypeFolder,FolderName,'\\',SegmentFolder); 
%             
%             % Check if directory exists, if not create a directory
%             if(exist(segmentDir,'dir')==0)
%                 mkdir(dir);
%             
%             % Change the global flag to false so we don't do this again
%             segmentDirectoryFlag=false;
%             end
%         end         
%     end    
%% Write File Name. Online RT does not write date
    
%     if(write2FileFlag)
%         % Retrieve Data
%         date    = clock;            % y/m/d h:m:s
%         h       = num2str(date(4));
%         min     = date(5);          % minutes before 10 appear as '9', not '09'. 
% 
%         % Fix appearance of minutes
%         if(min<10)                              % If before 10 minutes
%             min = strcat('0',num2str(min));
%         else
%             min = num2str(min);
%         end
% 
%         % Create a time sensitive name for file
%         FileName    = strcat(segmentDir,'\\','Segement_',Type,h,min,'.txt');
%        
%        % Change flag
%        write2FileFlag = false;
%     else

    % Modified for Online Generation
    % Provide Name according to Type
    if(strcmp(Type,'Fx'))
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_Fx.txt';
    elseif(strcmp(Type,'Fy'))
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_Fy.txt';
    elseif(strcmp(Type,'Fz'))
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_Fz.txt';
    elseif(strcmp(Type,'Mx'))
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_Mx.txt';
    elseif(strcmp(Type,'My'))
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_My.txt';
    else
        FileName = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/Segments/Segment_Mz.txt'; 
    end
        %FileName    = strcat(segmentDir,'\\','Segement_',Type,'.txt');   
%     end
   
%% Open the file

    % Use ceval
    % Declare 'f' as an opaque type 'FILE *'
    fid = coder.opaque('FILE *', 'NULL');
    % % Open file in binary mode
    fid = coder.ceval('fopen', [FileName 0], ['a+t' 0]);
    %fid = coder.ceval('fopen', coder.ref(FileName), ['a+t' 0]);
    %fid = fopen(FileName, 'a+t');	% Need to create a routine that eliminates existing files if they are there when this is called the first time
                                    % Open/create new file 4 writing in text mode 't'
                                    % Append data to end of file.
    %% EncoderRemoved: not sure how to handle fid. so Remove this part of code.                                    
    %     while(fid<0)
    % %        %% EncoderIncompatibility: pause(0.100);               % Wait 0.1 secs
    %         fid = fopen(FileName, 'a+t');
    %     end

%% Print the data to screen and to file

    %% Encoder does not allow 
%     if(fid~= 0)
        %% Sample
        %----------------------------------------------------------------------------------------------
        %  fprintf('Time level %-*.*f [s], Iterations: %d\n',field_width,precision,time,iter);
        %  s1=['%s%-*.*f%s%d' 10 0];  // new line null character
        %  s2=['Time level ' 0];
        %  s3=['[s], Iterations: ' 0];
        %  iter = 32;
        %  time = 2.5;
        %  field_width=int32(20);
        %  precision=int32(3);
        %  coder.ceval('fprintf',s1,s2,field_width,precision,time,s3,int32(iter))
        %----------------------------------------------------------------------------------------------
        
        
        % fprintf(fid, 'Iteration : %d\n',   segmentIndex);        
        s11=['%s%d' 10 0];  s12=['Iteration : ' 0];             % s11-Sets the overall structure of the input argument. That is: (1) string, (2) delimeter, (3) new line character, (4) null character for termination.
                                                                % s12-Includes the input that will be used by delimeter %s
        coder.ceval('fprintf',fid,s11,s12,int32(segmentIndex)); % Finally, include the numerical value for delimeter %d but mut assign type/size.
        
        % fprintf(fid, 'Average   : %.5f\n', dAvg);
        s21=['%s%.*f' 10 0];    s22=['Average   : ' 0];   precision=int32(5);               
        coder.ceval('fprintf',fid,s21,s22,precision,dAvg);      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
         
        % fprintf(fid, 'Max Val   : %.5f\n', dMax);
        s22=['Max Val   : ' 0];               
        coder.ceval('fprintf',fid,s21,s22,precision,dMax);      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
 
        % fprintf(fid, 'Min Val   : %.5f\n', dMin);
        s22=['Min Val   : ' 0];               
        coder.ceval('fprintf',fid,s21,s22,precision,dMin);      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
         
        % fprintf(fid, 'Start     : %.5f\n', dStart);
        s22=['Start    : ' 0];               
        coder.ceval('fprintf',fid,s21,s22,precision,dStart);    % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                 
        % fprintf(fid, 'Finish    : %.5f\n', dFinish);
        s22=['Finish   : ' 0];               
        coder.ceval('fprintf',fid,s21,s22,precision,dFinish);   % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                         
        % fprintf(fid, 'Gradient  : %.5f\n', dGradient);               
        s22=['Gradient  : ' 0];               
        coder.ceval('fprintf',fid,s21,s22,precision,dGradient); % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                  
        % Convert dLabel to a string
%         if(ischar(dGradient))
%             fprintf(fid, 'Grad Label: %s  \n', dLabel);
%         else
              dLabel = gradInt2gradLbl(dLabel);
%             fprintf(fid, 'Grad Label: %s  \n', dLabel);
              s31=['%s%s' 10 0];    s32=['Grad Label: ' 0];
              coder.ceval('fprintf',fid,s31,s32,char(dLabel));
%             fprintf(fid, '\n');    
              coder.ceval('fprintf',fid,'10 0');
%         end
%     else
%         msgbox('FileID null. FID is: ', num2str(fid),...
%                '\nFileName is: ',       FileName,...
%                '\nSegmentIndes is: ',   num2str(segmentIndex));
%     end
    
%% Close the file
    %% EndoderIncompatible: fclose(fid);   
    coder.ceval('fclose',fid);
end