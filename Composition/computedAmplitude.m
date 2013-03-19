%%********************** Documentation ************************************
% Used to compute the amplitude between composites composed of two
% primitives, where the first primitive could be pos/neg/constant/impulse
% and the second one can also be pos/net/constant/impulse. 
% 
% Find the maximum distance between the two extremes. Sometimes this could
% be find in the same primitive. Sometimes one primitive has one extreme
% and the other primitive has the other extreme. (The other alternative is
% to take the extrmeme of each primitive according to sign and compute the
% difference - not used here).
% 
% Input Parameters: 
% p1type:   - string. the type of the 1st primitive pos/neg/const/impulse.
% p2type:   - string. the type of the 2nd primitive pos/neg/const/impulse.
% p1maxmin: - [p1max p1min], 1x2 vec that holds max and min vals
% p2maxmin: - [p1max p1min], 1x2 vec that holds max and min vals
%
% Output Parameters:
% amplitude: maximum distance between two primitives. 
%**************************************************************************
function amplitude=computedAmplitude(p1type,p2type,p1maxmin,p2maxmin)

%% Positive p1
    % Pos,Neg
    if(strcmp(p1type,'pos') && strcmp(p2type,'neg'))
        
        % Retrieve p1max,p2min
        p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0 || p1<0 && p2<0)
            
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p1 - p2;
            
        
        % p1=pos,p2=neg or 
        else
            amplitude = p1-p2;
        end
        
    % Pos,pos
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'pos'))
        
        % Retrieve p1min,p2max
        p1 = p1maxmin(1,2); p2 = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0 || p1<0 && p2<0)
            
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p2-p1;
        
        % p1=neg,p2=pos or 
        else
            amplitude = p2-p1;
        end        
    
    % pos,const
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'const'))
        
        % Retrieve p1min,p2max
        p1 = p1maxmin(1,2); p2 = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0 || p1<0 && p2<0)
            
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p2-p1;
        
        % p1=neg,p2=pos or 
        else
            amplitude = p2-p1;
        end

    % pos,impulse
    elseif(strcmp(p1type,'pos') && strcmp(p2type,'impulse'))
        
        % Retrieve p1min,p2max
        p1 = p1maxmin(1,2); p2 = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0 || p1<0 && p2<0)
            
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p2-p1;
        
        % p1=neg,p2=pos or 
        else
            amplitude = p2-p1;
        end                      
    
%% Negative p1
    
    % neg,pos
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'pos'))
        
        % Retrieve p1min,p2max
        p1 = p1maxmin(1,2); p2 = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0)            
            amplitude = p2-p1;
        
        % If both negative
        elseif(p1<0 && p2<0)
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p1-p2;
            
        % p1=neg,p2=pos or 
        else
            amplitude = p2-p1;
        end        
            
    % Neg,neg
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'neg'))
        
        % Retrieve p1max,p2min
        p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(p1>0 && p2>=0 || p1>0 && p2<0)           
            amplitude = p1-p2;
        
        % If both neg 
        else
            amplitude = abs(p2)-abs(p1);
        end        
              
    % Neg,const
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'const'))

        % Retrieve p1max,p2min
        p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(p1>0 && p2>=0 || p1>0 && p2<0)           
            amplitude = p1-p2;
        
        % If both neg 
        else
            amplitude = abs(p2)-abs(p1);
        end 
        
    % Neg,impulse 
    elseif(strcmp(p1type,'neg') && strcmp(p2type,'impulse'))
    
    	%% Negative impulse
        
        % Retrieve p1max,p2min
        p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or p1=pos,p2=neg:
        if(p1>0 && p2>=0 || p1>0 && p2<0)           
            amplitude = p1-p2;
        
        % If both neg 
        else
            amplitude = abs(p2)-abs(p1);
        end        

%% Constant p1
    % const p1 followed by a pos p2
    elseif(strcmp(p1type,'const') && strcmp(p2type,'pos'))
    
        % Retrieve p1min,p2max
        p1 = p1maxmin(1,2); p2 = p2maxmin(1,1);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1>0 && p2>=0 || p1<0 && p2<0)
            
            % Compute the absolute values
            p1=abs(p1); p2=abs(p2);
            amplitude = p2-p1;
        
        % p1=min,p2=pos  
        else
            amplitude = p2-p1;
        end

    %% const followed by a neg
    elseif(strcmp(p1type,'const') && strcmp(p2type,'neg'))

        % Retrieve p1max,p2min
        p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);
        
        %% Compute amplitude depending on signs
        % If both positive or negative:
        if(p1<0 && p2<0)
            
            % Compute the absolute values
            amplitude = abs(p2)-abs(p1);            
        
        % p1>0,p2>0 or p1>0,p2<0
        else
            amplitude = p1-p2;
        end
    %else const, const. amplitude = 0. covered in the 'else' case. 

%% Impulse p1
    elseif(strcmp(p1type,'impulse') && strcmp(p2type,'pos'))
        
        %% Check to see which is greater p1max or p2max
        % p1max is greater
        if(p1maxmin(1,1) > p2maxmin(1,1))
            
            % p1max,p2max
            p1 = p1maxmin(1,1); p2 = p2maxmin(1,1);

            %% Compute amplitude depending on signs
            % If both positive or p1 is pos and p2 is neg:
            if(p1>0 && p2>=0 || p1>0 && p2<0)
                amplitude = p1 - p2;
            
            % If both neg 
            else
                amplitude = abs(p2)-abs(p1);
            end
            
        % p2max is greater
        else
            p1 = p1maxmin(1,1); p2 = p2maxmin(1,1);

            %% Compute amplitude depending on signs
            % If both positive or p1 is neg and p2 is pos:
            if(p1>0 && p2>=0 || p1<0 && p2>0)
                amplitude = p2-p1;
            
            % Ig both neg
            else
                amplitude = abs(p2)-abs(p1);
            end            
        end
        
    % impulse,neg
    elseif(strcmp(p1type,'impulse') && strcmp(p2type,'neg'))
        
        %% Check to see which is greater p1max or p2max
        % p1max is greater
        if(p1maxmin(1,1) > p2maxmin(1,1))
            
            % p1max,p2min
            p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);

            %% Compute amplitude depending on signs
            % If both positive or p1 is pos and p2 is neg:
            if(p1>0 && p2>=0 || p1>0 && p2<0)
                amplitude = p1 - p2;
            
            % If both neg 
            else
                amplitude = abs(p2)-abs(p1);
            end
            
        % p2max is greater
        else
            %p1max,p2min
            p1 = max([p1maxmin p2maxmin]); p2 = min([p1maxmin p2maxmin]);

            %% Compute amplitude depending on signs
            % If both positive or p1 is neg and p2 is pos:
            if(p1>0 && p2>=0 || p1<0 && p2>0)
                amplitude = p2-p1;
            
            % Ig both neg
            else
                amplitude = abs(p1)-abs(p2);
            end            
        end
    else
        amplitude=0;        
    end
    
    % Make sure to return a scalara value. Take the absolute value.
    amplitude = abs(amplitude);
end