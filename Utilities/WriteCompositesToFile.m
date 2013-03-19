%% ************************** Documentation *********************************
% Write to file, statistical data used in fitRegressionCurves to analyze 
% segmented portions of force-moment data.
%
% Input Variables:
% fPath              : path string to the "Results" directory
% StratTypeFolder   : path string to Position/Force Control and Straight Line
%                     approach or Pivot Approach.
% Foldername        : name of folder of data we are handling
% pType             : type of data to analyze: Fx,Fy,Fz,Mx,My,Mz. Not
%                     applicable to probabilities.
% saveData          : flag that indicates whether to save .mat to file
% data              : data to be saved. motComps 1x11, llBehStruc 1x17
% dataFlag          : indicates the kind of data to be saved.
%                     motComps      = 0;
%                     llbehStruc    = 1;
%                     hlbehStruc    = 2;
%                     llbBelief     = 3;
%
% Modifications:
% July 2012 - to facilitate the conversion from Matlab to C++ all cells
% have been eliminated. String2Int and Int2String conversions are done when
% necessary to avoid the use of cells. 
% We write to file data with string labels to make it easier to read. 
%**************************************************************************
function FileName=WriteCompositesToFile(WinPath,StratTypeFolder,FolderName,pType,saveData,data,dataFlag)

%% Initialization

    % Set the linux path to the pivot approach where we will save composites
    LinuxPath   = coder.opaque('char *','NULL');
    %LinuxPath   = char('/home/vmrguser/src/OpenHRP-3.0/Controller/IOserver/robot/HRP2STEP1/bin/temp/');
    LinuxPath   = '/home/grxuser/src/OpenHRP3.0-HRP2STEP1/Controller/IOserver/robot/HRP2STEP1/bin/pRCBHT/';
    tempChar = char(1,3);
            
    % Initialize return type of file opening
    fid         = coder.opaque('FILE *','NULL');         % Stream return type is an int
    FileName    = coder.opaque('char'  ,'NULL');         % Filename is a char
    dir         = coder.opaque('char'  ,'NULL');         % type, val
    
    % Structures
    motComps      = 0;
    llbehStruc    = 1;
    hlbehStruc    = 2;
    llbBelief     = 3;

%% Create Directory According to Data
    %% Updated to work online 
    if(dataFlag==motComps)
        Folder='Composites';        
    elseif(dataFlag==llbehStruc)
        Folder='llBehaviors';
    elseif(dataFlag==hlbehStruc)
        Folder='hlBehaviors';
    elseif(dataFlag==llbBelief)
        Folder='llbBelief';
    end        
    
%%  Generate the Directory fPath
%     if(ispc)
%         % Set path with new folder "Composites" in it.
%         dir          = strcat(WinPath,StratTypeFolder,FolderName,'\\',Folder);                    
%     else % Linux

        %% Matlab Coder
        % 1) Set the output C++ type that will go with strcat
        % May need to set each string in strcat with the following
        % directive: str1=coder.nullcopy(char(zeros(1,256)));
        
        % Use coder.ceval to call strcat. Two parameters at a time.
        dir = coder.ceval('strcat', LinuxPath,[StratTypeFolder 0]);
        dir = coder.ceval('strcat', dir, [FolderName 0]);
        dir = coder.ceval('strcat', dir, ['\\' 0]);
        dir = coder.ceval('strcat', dir, [Folder 0] );         
%     end 

    % Check if directory exists, if not create a directory
    %% EncoderIncompatible: if(exist(dir,'dir')==0)
    %%    mkdir(dir);
    %% end     
%% Write File Name with date
    
%   if(write2FileFlag)
    % Retrieve Data
%     date	= clock;                % y/m/d h:m:s
%     h       = num2str(date(4));     % hours
%     min     = date(5);              % minutes before 10 appear as '9', not '09'. 
%         
%     % Fix appearance of minutes when under the 10 minute mark
%     if(min<10)                              
%         min = strcat('0',num2str(min));
%     else
%         min = num2str(min);
%     end

%%  Create a time sensitive name for file according to data
    if(dataFlag==motComps)
        %% Matlab Coder strcat format.
        % 1) Set output

        % FileName= strcat(dir,'\\',Folder,'_',pType);%,h,min); 
        %% Note if the code below does not work in runtime, consider changing coder.ref(dir) to [dir 0]. Same for the rest of terms.
        FileName = coder.ceval('strcat', dir, ['\\' 0]);
        FileName = coder.ceval('strcat', FileName, [Folder 0]);
        FileName = coder.ceval('strcat', FileName, ['_' 0]);
        FileName = coder.ceval('strcat', FileName, [pType 0]);%,h,min);

    elseif(dataFlag==llbehStruc)
        %FileName_temp = strcat(dir,'\\',Folder,'_',pType);      % File with no date/time, useful to open from other programs.
        %FileName    = strcat(dir,'\\',Folder,'_',pType);%,h,min);
        FileName = coder.ceval('strcat', dir, ['\\' 0]);
        FileName = coder.ceval('strcat', FileName, [Folder 0]);
        FileName = coder.ceval('strcat', FileName, ['_' 0]);
        FileName = coder.ceval('strcat', FileName, [pType 0] );%,h,min);

    elseif(dataFlag==hlbehStruc)
        %FileName    = strcat(dir,'\\',Folder,'_',pType);%,h,min);   
        FileName = coder.ceval('strcat', dir, ['\\' 0]);
        FileName = coder.ceval('strcat', FileName, [Folder 0]);
        FileName = coder.ceval('strcat', FileName, ['_' 0]);
        FileName = coder.ceval('strcat', FileName, [pType 0] );%,h,min);
        
    elseif(dataFlag==llbBelief)
        %FileName = strcat(dir,'\\Data');                % File with no date/time, useful to open from other programs
        FileName = coder.ceval('strcat',dir,['\\Data' 0]);

    end
    
    %FileExtension = strcat(FileName,'.txt');
    %FileExtension = coder.opaque('char','NULL');
    FileName = coder.ceval('strcat', FileName, ['.txt' 0]);
%        Change flag
%        write2FileFlag = false;
    
%% Open the file
    if(dataFlag~=llbBelief)
        
        % Use ceval

        % % Open file in binary mode
        fid = coder.ceval('fopen', FileName, ['a+t' 0]);
        %% EncoderIncompatibility: fid = fopen(FileExtension, 'a+t');	% Open/create new file 4 writing in text mode 't'
                                            % Append data to end of file.
        % while(fid<0)
        %     pause(0.100);                   % Wait 0.1 secs
        %     fid = fopen(FileExtension, 'a+t');
        % end
        
%% Print the data to screen and to file (except for dataFlag=llbBelief)
        r= size(data); %rows
%         if(fid>0)
                if(dataFlag==motComps)
                    for i=1:r(1)
                        % fprintf(fid, 'Iteration     : %d\n',   i);
                        s11=['%s%d' 10 0];  s12=['Iteration     : ' 0]; % s11-Sets the overall structure of the input argument. That is: (1) string, (2) delimeter, (3) new line character, (4) null character for termination.
                                                                        % s12-Includes the input that will be used by delimeter %s
                        coder.ceval('fprintf',fid,s11,s12,int32(i));     % Finally, include the numerical value for delimeter %d but mut assign type/size.
        
                        %fprintf(fid, 'Label         : %s\n',   actionInt2actionLbl(data(i,1)));
                        tempChar=actionInt2actionLbl(data(i,1));
                        s31=['%s%s' 10 0];    s32=['Label         : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
              
                        %fprintf(fid, 'Average Val   : %.5f\n', data(i,2));                  
                        s21=['%s%.*f' 10 0];    s22=['Average Val   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,2));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.

                        %fprintf(fid, 'RMS Val       : %.5f\n', data(i,3));                    
                        s21=['%s%.*f' 10 0];    s22=['RMS Val       : ' 0];    	precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,3));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                        
                        %fprintf(fid, 'Amplitude Val : %.5f\n', data(i,4));                       
                        s21=['%s%.*f' 10 0];    s22=['Amplitude Val : ' 0];   	precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,4));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                
                        %fprintf(fid, 'Label 1       : %s\n',   gradInt2gradLbl(data(i,5))); % Modified July 2012
                        tempChar=gradInt2gradLbl(data(i,5));                        
                        s31=['%s%s' 10 0];    s32=['Label 1       : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
                                                           
                        %fprintf(fid, 'Label 2       : %s\n',   gradInt2gradLbl(data(i,6)));
                        tempChar=gradInt2gradLbl(data(i,6));                        
                        s31=['%s%s' 10 0];    s32=['Label 2       : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
                        
                        %fprintf(fid, 't1Start       : %.5f\n', data(i,7));
                        s21=['%s%.*f' 10 0];    s22=['t1Start       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,7));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                        
                        %fprintf(fid, 't1End         : %.5f\n', data(i,8));  
                        s21=['%s%.*f' 10 0];    s22=['t1End         : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,8));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                
                        %fprintf(fid, 't2Start       : %.5f\n', data(i,9));
                        s21=['%s%.*f' 10 0];    s22=['t2Start       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,9));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                
                        %fprintf(fid, 't2End         : %.5f\n', data(i,10));   
                        s21=['%s%.*f' 10 0];    s22=['t2End         : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,10));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                        
                        %fprintf(fid, 'tAvgIndex     : %.5f\n', data(i,11));
                        s21=['%s%.*f' 10 0];    s22=['tAvgIndex     : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,11));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                        
                        %fprintf(fid, '\n');    
                        coder.ceval('fprintf',fid,'10 0');
                    end   
                else
                    for i=1:r(1)
                        % fprintf(fid, 'Iteration     : %d\n',   i);
                        s11=['%s%d' 10 0];  s12=['Iteration     : ' 0]; % s11-Sets the overall structure of the input argument. That is: (1) string, (2) delimeter, (3) new line character, (4) null character for termination.
                                                                        % s12-Includes the input that will be used by delimeter %s
                        coder.ceval('fprintf',fid,s11,s12,int32(i));     % Finally, include the numerical value for delimeter %d but mut assign type/size.
                                
                        % fprintf(fid, 'CompLabel     : %s\n',   actionInt2actionLbl(data(i,1)));
                        tempChar=actionInt2actionLbl(data(i,1));
                        s31=['%s%s' 10 0];    s32=['Label         : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
                        
                        % fprintf(fid, 'averageVal1   : %.5f\n', data(i,2));
                        s21=['%s%.*f' 10 0];    s22=['averageVal1   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,2));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                        
                        % fprintf(fid, 'averageVal2   : %.5f\n', data(i,3));
                        s21=['%s%.*f' 10 0];    s22=['averageVal2   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,3));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                
                        % fprintf(fid, 'AVG_MAG_VAL   : %.5f\n', data(i,4));  
                        s21=['%s%.*f' 10 0];    s22=['AVG_MAG_VAL   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,4));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                
                        % fprintf(fid, 'rmsVal1       : %.5f\n', data(i,5));
                        s21=['%s%.*f' 10 0];    s22=['rmsVal1       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,5));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                        
                        % fprintf(fid, 'rmsVal2       : %.5f\n', data(i,6));
                        s21=['%s%.*f' 10 0];    s22=['rmsVal2       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,6));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                                
                        % fprintf(fid, 'AVG_RMS_Val   : %.5f\n', data(i,7)); 
                        s21=['%s%.*f' 10 0];    s22=['AVG_RMS_Val   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,7));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                                  
                        % fprintf(fid, 'amplitudeVal1 : %.5f\n', data(i,8));
                        s21=['%s%.*f' 10 0];    s22=['amplitudeVal1 : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,8));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                          
                        % fprintf(fid, 'amplitudeVal2 : %.5f\n', data(i,9));
                        s21=['%s%.*f' 10 0];    s22=['amplitudeVal2 : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,9));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                  
                        % fprintf(fid, 'AVG_AMP_VAL   : %.5f\n', data(i,10));                    
                        s21=['%s%.*f' 10 0];    s22=['aAVG_AMP_VAL   : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,10));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                  
                        % fprintf(fid, 'Label 1       : %s\n',   gradInt2gradLbl(data(i,11)));
                        tempChar=gradInt2gradLbl(data(i,11));                        
                        s31=['%s%s' 10 0];    s32=['Label 1       : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
                        
                        % fprintf(fid, 'Label 2       : %s\n',   gradInt2gradLbl(data(i,12)));
                        tempChar=gradInt2gradLbl(data(i,12));                        
                        s31=['%s%s' 10 0];    s32=['Label 2       : ' 0];
                        coder.ceval('fprintf',fid,s31,s32,char(tempChar));
                        
                        % fprintf(fid, 't1Start       : %.5f\n', data(i,13));
                        s21=['%s%.*f' 10 0];    s22=['t1Start       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,13));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                                       
                        % fprintf(fid, 't1End         : %.5f\n', data(i,14));  
                        s21=['%s%.*f' 10 0];    s22=['t1End         : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,14));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                                  
                        % fprintf(fid, 't2Start       : %.5f\n', data(i,15));
                        s21=['%s%.*f' 10 0];    s22=['t2Start       : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,15));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                                   
                        % fprintf(fid, 't2End         : %.5f\n', data(i,16));      
                        s21=['%s%.*f' 10 0];    s22=['t2End         : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,16));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                               
                        % fprintf(fid, 'tAvgIndex     : %.5f\n', data(i,17));
                        s21=['%s%.*f' 10 0];    s22=['tAvgIndex     : ' 0];     precision=int32(5);               
                        coder.ceval('fprintf',fid,s21,s22,precision,data(i,17));      % Precision indicates how many figures for %f. If no size/type assign to dAvg it defaults to double.
                                                                               
                        %fprintf(fid, '\n');    
                        coder.ceval('fprintf',fid,'10 0');
                    end                   
                end
%         EncoderIncompatibility:
%         else
%             msgbox('FileID null. FID is: ', num2str(fid),...
%                    '\nFileName is: ',       FileExtension,...
%                    '\nSegmentIndes is: ',   num2str(segmentIndex));
%         end
    end
    
%%  Save to composites folder
%% EncoderIncompatibility: if(saveData)
%         % Save motcomps.mat to Composites folder 
%         % save filename content stores only those variables specified by content in file filename
%         save(strcat(FileName,'.mat'),'data');
        
%         if(dataFlag==llbehStruc)
%             save(strcat(FileName_temp,'.mat'),'data');
%         end
%    end     
%% Close the file
    if(dataFlag~=llbBelief)
        %fclose(fid);  
        coder.ceval('fclose',fid);
    end
end