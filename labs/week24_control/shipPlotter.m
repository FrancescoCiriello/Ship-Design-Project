classdef shipPlotter < matlab.System
    % A custom plotter for Simulink that uses a MATLAB Figure
    %
    % This MATLAB System object must be run in interpreted mode. 

    % Public, tunable properties
    properties
        fixedAxis = true;
        xLim = [-1 1];
        yLim = [-1 1];
    end

    properties(Nontunable)
        FigureName = 'Ship Trajectory';
        FigureTag = 'ShipViewer';
        xLabel = '$x$';
        yLabel = '$y$';
        lineColor = [ 0.1843    0.4941    0.6980];
        lineWidth = 1;

    end


    % Pre-computed constants
    properties(Access = private)
        fig;
        ax;
        h;
        ship;
        handInit = true;
        FontSize = 14;
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
            obj.ax.FontSize = obj.FontSize;
            obj.ax.TickLabelInterpreter = "latex";
            hold(obj.ax,'on');

            % Initialise handle
            obj.h = plot(0,0);
            if ~isempty(obj.h)
                obj.h.YData = obj.h.YData;
            end
            obj.h.Color = obj.lineColor;
            obj.h.LineWidth = obj.lineWidth;

            %  Initialise ship
            obj.ship = plot([0 0.05],[0 0],'-','linewidth',4);
            if ~isempty(obj.ship)
                obj.ship.YData = obj.ship.YData;
            end


            % Final setup
            title(obj.ax, obj.FigureName);
            if obj.fixedAxis
                xlim(obj.ax, obj.xLim)
                ylim(obj.ax, obj.yLim)
            end
            xlabel(obj.ax, obj.xLabel, 'Interpreter', "latex")
            ylabel(obj.ax, obj.yLabel, 'Interpreter', "latex")
            obj.ax.Box = 'on';
            hold(obj.ax,'off');
            
        end

        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 3;

        end

        function stepImpl(obj,x,y,theta)
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

            % update ship location
            obj.ship.XData = [x, x+0.05*cos(theta)];
            obj.ship.YData = [y, y+0.05*sin(theta)];

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
