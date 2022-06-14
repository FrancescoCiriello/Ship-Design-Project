classdef customScope < matlab.System
    % A custom plotter for Simulink that uses a MATLAB Figure
    %
    % This MATLAB System object must be run in interpreted mode. 

    % Public, tunable properties
    properties
        fixedAxis = true;
        xLim = [0 1];
        yLim = [0 1];
    end

    properties(Nontunable)
        FigureName = 'Custom Scope Viewer';
        FigureTag = 'CustomScopeViewer';
        xLabel = 'x';
        yLabel = 'y';
        lineColor = [ 0.1843    0.4941    0.6980];
        lineWidth = 2;
    end


    % Pre-computed constants
    properties(Access = private)
        fig;
        ax;
        h;
        handInit = true;
    end

    methods(Access = protected)
        function setupImpl(obj)
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
            obj.h = plot(0,0);
            if ~isempty(obj.h)
                obj.h.YData = obj.h.YData;
            end
            obj.h.Color = obj.lineColor;
            obj.h.LineWidth = obj.lineWidth;
            
            % Final setup
            title(obj.ax, obj.FigureName);
            if obj.fixedAxis
                xlim(obj.ax, obj.xLim)
                ylim(obj.ax, obj.yLim)
            end
            xlabel(obj.ax, obj.xLabel)
            ylabel(obj.ax, obj.yLabel)
            obj.ax.Box = 'on';
            hold(obj.ax,'off');
            
        end

        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 2;

        end

        function stepImpl(obj,x,y)
            % Implement algorithm. 
            
%             Check for closed figure
            if ~isvalid(obj.fig)
                return;
            end
            
            % update handle
            if obj.handInit == true
                obj.h.XData = x;
                obj.h.YData = y;
                obj.handInit = false;
            else
                set(obj.h, 'xdata', [obj.h.XData x], ...
                    'ydata', [obj.h.YData y])
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
