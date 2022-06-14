classdef customScatter < matlab.System
    % A custom plotter for Simulink that uses a MATLAB Figure
    %
    % This MATLAB System object must be run in interpreted mode. 

    % Public, tunable properties
    properties
        fixedAxis = false;
        xLim = [0 1];
        yLim = [0 1];
        sz = 50;
        cmax = 100;
        cmin = 10;
        cmap = parula(255);
    end

    properties(Nontunable)
        FigureName = 'Custom Scatter Viewer';
        FigureTag = 'CustomScatterViewer';
        xLabel = 'x';
        yLabel = 'y';

    end


    % Pre-computed constants
    properties(Access = private)
        fig;
        ax;
        h;
        cb;
        handInit = true;
    end

    methods(Access = protected)
        function setupImpl(obj,u)
            % Perform one-time calculations, such as computing constants

            
            % Create figure & axis
            existingFigures = findobj('type','figure','tag', obj.FigureTag);
            if ~isempty(existingFigures)
                obj.fig = figure(existingFigures(1)); % bring figure to the front
                clf;
            else
                obj.fig = figure('Name', obj.FigureName,'tag', obj.FigureTag, 'color','w');
            end
            obj.ax = axes('parent', obj.fig);
            hold(obj.ax,'on');
                      
            
            % Initialise handle
            obj.h = scatter(0, 0, obj.sz,0,'filled','markeredgecolor','k');
            if ~isempty(obj.h)
                obj.h.YData = obj.h.YData;
            end
            
            % Final setup
            title(obj.ax, obj.FigureName);
            if obj.fixedAxis
                xlim(obj.ax, obj.xLim)
                ylim(obj.ax, obj.yLim)
            end
            xlabel(obj.ax, obj.xLabel)
            ylabel(obj.ax, obj.yLabel)
            obj.ax.Box = 'on';
            obj.cb = colorbar(obj.ax);
            obj.cb.Title.String = 'c';
            obj.cb.Limits = [obj.cmin obj.cmax];
            hold(obj.ax,'off');
            
        end

        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 3;
        end


        function stepImpl(obj,x,y,c)
            % Implement algorithm. 
            
            % Check for closed figure
            if ~isvalid(obj.fig)
                return;
            end
            
            % update handle
            if obj.handInit == true
                obj.h.XData = x;
                obj.h.YData = y;
                
                % index into colormap (with saturation)
                cidx = min( max(round(c/abs(obj.cmax - obj.cmin)*size(obj.cmap,1)), 1) , size(obj.cmap,1));
                obj.h.CData = obj.cmap(cidx,:);
                
                obj.handInit = false;
            else
                
                % index into colormap (with saturation)
                cidx = min( max(round(c/abs(obj.cmax - obj.cmin)*size(obj.cmap,1)), 1) , size(obj.cmap,1));

                % update data
                set(obj.h, 'xdata', [obj.h.XData x], ...
                    'ydata', [obj.h.YData y], ...
                    'cdata', [obj.h.CData; obj.cmap(cidx,:)]);
            end
            
            % Update the figure
            drawnow('limitrate')
        end

    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end
    end
end
