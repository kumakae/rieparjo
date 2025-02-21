classdef Plain < handle
    %PLAIN Saves state of the plain
    
    properties(SetAccess = public)
        ground;         % The current ground structure
        initialGround;  % inital ground model
        groundMax;      % The maximum values of the walking comfort
        intensity;      % The footprint intensity
        durability;     % The durability of trails
        visibility;     % The visibility at each point
        realGround;     % real, not inverted, ground
        gridSize;       % grid size of plain in m
        relativePath;   % relative strength of path
    end
   
    methods
        function obj=Plain(aInitialGround,aGroundMax,aIntensity,...
                aDurability,aVisibility,aRealGround,aGridSize)
            initSize = size(aInitialGround);
            % Check if initialGround has same size as intensity and
            % durability matrix
           
            if((nnz(initSize == size(aIntensity)) == 2) &&...
                    (nnz(initSize == size(aDurability))==2) &&...
                    (nnz(initSize == size(aGroundMax))==2) &&...
                    (nnz(initSize == size(aVisibility))==2) &&...
                    (nnz(initSize == size(aRealGround))==2))
                
                obj.ground = aInitialGround;
                obj.groundMax = aGroundMax;
                obj.initialGround = aInitialGround;
                obj.intensity = aIntensity;
                obj.durability = aDurability;
                obj.visibility = aVisibility;
                obj.realGround = aRealGround;
                obj.gridSize = aGridSize;
            else
                error('PLAIN(): initialGround must be same size as intensity and durability');
            end
        end
        
        function changeEnvironment(obj,pedestrians)
            % Changes the environment according to the positions of the
            % pedestrians
            [n m] = size(obj.ground);
            pedAt = sparse(n,m);
            
            for i=1:length(pedestrians)
                ped = pedestrians(i);
                pedAt(ped.position(1),ped.position(2)) = ...
                    pedAt(ped.position(1),ped.position(2)) + 1;
            end
            
            % Change the environment on each square of the plain
            for i=1:n
                for j=1:m
                    % Change the ground according to the formula
                    obj.ground(i,j) = obj.ground(i,j) + ...
                        1/obj.durability(i,j) * (obj.initialGround(i,j)-...
                        obj.ground(i,j)) + obj.intensity(i,j) * ...
                        (1-(obj.ground(i,j)/obj.groundMax(i,j))) * ...
                        pedAt(i,j);
                    
                    % Check for the boundaries of the ground values
                    if(obj.ground(i,j) > obj.groundMax(i,j))
                        obj.ground(i,j) = obj.groundMax(i,j);
                    elseif(obj.ground(i,j) < obj.initialGround(i,j))
                        obj.ground(i,j) = obj.initialGround(i,j);
                    end
                end
            end
                
        end        
        
        function val = isPointInPlain(obj,y,x)
            % Returns wheter or not a point (x,y) is in this plain
            val = (y>0 && x>0);
            val = val && y<=size(obj.ground,1) && x<=size(obj.ground,2);

        end
        
        function MakeRelativePath(obj)
            % Calculates relative path strength (1 = maximal path)
            obj.relativePath = (obj.ground-obj.initialGround)./...
                (obj.groundMax-obj.initialGround);
        end
    end
    
end

