%% ************************** Documentation *********************************
% Two options:
% 1) First write only extremem data points: pimp and pConst.
% 2) Write the entire gradient classification structure.
% The second choice is done after the relevant gradient classification
% values have been computed as per described in gradientCalibration()
function WriteGradientClassification(WinPath,StratTypeFolder,gradClassification,index)                                           

%% Create Directory   
    if(ispc)
        % Set path with new folder "Segments" in it.
        gradClassFolder = 'gradClassFolder';
        dir             = strcat(WinPath,StratTypeFolder,gradClassFolder);        
    % Linux
    else
        gradClassFolder='gradClassFolder';
        LinuxPath   = '\\home\\Documents\\Results\\Force Control\\Pivot Approach\\';
        %QNXPath    = '\\home\\hrpuser\\forceSensorPlugin_Pivot\\data\\Results\\'
        dir         = strcat(LinuxPath,StratTypeFolder,gradClassFolder);        
    end    
 
    % Check if directory exists, if not create a directory
    if(exist(dir,'dir')==0)
        mkdir(dir);
    end     
        
%% Load values and copy appropriately
    if(index==1);         name='\\FxLims.dat';
    elseif(index==2);     name='\\FyLims.dat';
    elseif(index==3);     name='\\FzLims.dat';
    elseif(index==4);     name='\\MxLims.dat';
    elseif(index==5);     name='\\MyLims.dat';
    elseif(index==6);     name='\\MzLims.dat';
    end
    
%% Write Limits [pimp pConst] to File
    FileName = strcat(dir,name);
    fid = fopen(FileName, 'w+');                        % Open file, or create new file, for reading and writing; discard existing contents, if any.
                                                        % Append data to end of file.
    % For timing problems in opening files
    while(fid<0)
        pause(0.100);                               % Wait 0.1 secs
        fid = fopen(FileName, 'w+');
    end

%% Print the data to screen and to file
    if(fid>0)
        r = size(gradClassification);
        for j=1:r(2)
            fprintf(fid, '%.5f\n', gradClassification(1,j));       
        end

    else
        msgbox('FileID null. FID is: ', num2str(fid),...
               '\nFileName is: ',       FileName);
    end
    
%% Close the file
        fclose(fid); 
        
        
%% COMPUTE ENTIRE GRADIENT CLASSIFICATION STRUCTURE ONCE ALL SIX LIMITS HAVE BEEN COMPUTED                    
    if(index==6)
        
        % Load all 6 gradient limits : [pimp pConst]      
        FX = load(strcat(dir,'\\FxLims.dat'));
        FY = load(strcat(dir,'\\FyLims.dat'));
        FZ = load(strcat(dir,'\\FzLims.dat'));
        MX = load(strcat(dir,'\\MxLims.dat'));
        MY = load(strcat(dir,'\\MyLims.dat'));
        MZ = load(strcat(dir,'\\MzLims.dat'));              
        
%% Compute gradient classification values for each axes separately.

    % Start with Fx, Fz, My which are the key axes for the Pivot Approach
    
%% Fx   
        pimp    = FX(1,1);  % pimp - positive impulse
        pConst  = FX(2,1);  % pConst - positive constant
        Fx = computeGradientSpectrum(pimp,pConst);
        
%% Fy
        % Copy Fz's pimp AND Fx's pConst
        pimp    = FZ(1,1); 
        pConst  = FX(2,1);
        Fy = computeGradientSpectrum(pimp,pConst);        

%% Fz
        pimp    = FZ(1,1);  % pimp - positive impulse
        pConst  = FX(2,1);  % pConst - positive constant
        Fz = computeGradientSpectrum(pimp,pConst);        
    
%% Mx - These use My's pimp and pConst
        % Copy My's pimp into Mx
        pimp    = MY(1,1); %pimp
        pConst  = MY(2,1);
        Mx = computeGradientSpectrum(pimp,pConst);
        
%% My
        pimp    = MY(1,1);  % pimp - positive impulse
        pConst  = MY(2,1);  % pConst - positive constant
        My = computeGradientSpectrum(pimp,pConst);     

%% Mz
        % Copy My's pimp into Mz
        pimp    = MY(1,1)/10.0; %pimp
        pConst  = MY(2,1);
        Mz = computeGradientSpectrum(pimp,pConst);    

%% Save values to file
        for i=1:6

            if(i==1);       
                FileName=strcat(dir,'\\Fx.dat');
                data = Fx;
            elseif(i==2)  
                FileName=strcat(dir,'\\Fy.dat');
                data = Fy;
            elseif(i==3)
                FileName=strcat(dir,'\\Fz.dat');
                data = Fz;
            elseif(i==4)
                FileName=strcat(dir,'\\Mx.dat');
                data = Mx;
            elseif(i==5)
                FileName=strcat(dir,'\\My.dat');
                data = My;
            elseif(i==6)
                FileName=strcat(dir,'\\Mz.dat');
                data = Mz;
            end

            fid = fopen(FileName, 'w+');                   % Open/create new file 4 writing in text mode 't'
                                                            % Append data to end of file.
            % For timing problems in opening files
            while(fid<0)
                pause(0.100);                               % Wait 0.1 secs
                fid = fopen(FileName, 'w+');
            end

%% Print the data to screen and to file
            if(fid>0)
                r = size(data);
                for j=1:r(2)
                    fprintf(fid, '%.5f\n', data(1,j));       
                end

            else
                msgbox('FileID null. FID is: ', num2str(fid),...
                       '\nFileName is: ',       FileName);
            end

%% Close the file
            fclose(fid);  
        end % End FOR LOOP
    end     % END IF index==6
end         % End function