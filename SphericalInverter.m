classdef SphericalInverter < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SphericalInverterUIFigure    matlab.ui.Figure
        UIAxes                       matlab.ui.control.UIAxes
        InverseSpherePanel           matlab.ui.container.Panel
        RadiusEditFieldLabel         matlab.ui.control.Label
        InvRadBox                    matlab.ui.control.NumericEditField
        CenterLabel                  matlab.ui.control.Label
        XLabel                       matlab.ui.control.Label
        InvXBox                      matlab.ui.control.NumericEditField
        YLabel                       matlab.ui.control.Label
        InvYBox                      matlab.ui.control.NumericEditField
        ZLabel                       matlab.ui.control.Label
        InvZBox                      matlab.ui.control.NumericEditField
        InvVisBox                    matlab.ui.control.CheckBox
        SphericalInverterLabel       matlab.ui.control.Label
        DataPanel                    matlab.ui.container.Panel
        ResolutionSliderLabel        matlab.ui.control.Label
        ResSlider                    matlab.ui.control.Slider
        StepsSliderLabel             matlab.ui.control.Label
        StepSlider                   matlab.ui.control.Slider
        ShapeLabel                   matlab.ui.control.Label
        XEditField_2Label            matlab.ui.control.Label
        ShapeXBox                    matlab.ui.control.NumericEditField
        YEditField_2Label            matlab.ui.control.Label
        ShapeYBox                    matlab.ui.control.NumericEditField
        ZEditField_2Label            matlab.ui.control.Label
        ShapeZBox                    matlab.ui.control.NumericEditField
        RadiusEditField_2Label       matlab.ui.control.Label
        ShapeRadBox                  matlab.ui.control.NumericEditField
        AEditFieldLabel              matlab.ui.control.Label
        ARadBox                      matlab.ui.control.NumericEditField
        BEditFieldLabel              matlab.ui.control.Label
        BRadBox                      matlab.ui.control.NumericEditField
        CEditFieldLabel              matlab.ui.control.Label
        CRadBox                      matlab.ui.control.NumericEditField
        DrawShapeButton              matlab.ui.control.Button
        ShapeSelectionDropDownLabel  matlab.ui.control.Label
        ShapeSelectBox               matlab.ui.control.DropDown
        NumberofPointsSpinnerLabel   matlab.ui.control.Label
        CustomNumBox                 matlab.ui.control.Spinner
        CurrentPointDropDownLabel    matlab.ui.control.Label
        CurPointBox                  matlab.ui.control.DropDown
        CustomLabel                  matlab.ui.control.Label
        XEditField_2Label_2          matlab.ui.control.Label
        CustomXBox                   matlab.ui.control.NumericEditField
        YEditField_2Label_2          matlab.ui.control.Label
        CustomYBox                   matlab.ui.control.NumericEditField
        ZEditField_2Label_2          matlab.ui.control.Label
        CustomZBox                   matlab.ui.control.NumericEditField
        CustomDisclaim               matlab.ui.control.Label
        ShowPointsBox                matlab.ui.control.CheckBox
        HeightLabel                  matlab.ui.control.Label
        HeightBox                    matlab.ui.control.NumericEditField
        DimensionLabel               matlab.ui.control.Label
        FuncDimenBox                 matlab.ui.control.NumericEditField
        ZEditFieldLabel              matlab.ui.control.Label
        FuncZBox                     matlab.ui.control.EditField
        FuncLabel                    matlab.ui.control.Label
        InvButton                    matlab.ui.control.Button
    end

    
    properties (Access = private)
        % inverse sphere variables
        InvRad;
        InvX;
        InvY;
        InvZ;
        InvVis;
        InvSphere;
        
        % shape variables
        ShapeSelect;
        Res;
        Step;
        Coords;
        Shape;
        NumOfPoints
        % sphere
        ShapeX;
        ShapeY;
        ShapeZ;
        ShapeRad;
        % cylinder
        Height;
        % ellipsoid
        ARad;
        BRad;
        CRad;
        % custom
        CustomNum;
        CurPoint;
        CustomX;
        CustomY;
        CustomZ;
        
        % inverse variables
        Inverses;
        
        % graphical points variables
        ShowPlotPoints;
        Points;
        
        % function points variables
        FuncDimen;
        FuncX;
        FuncY;
        FuncZ;
        FuncMesh;
    end
    
    methods (Access = private)
        
        % generate inverse sphere based on user properties
        function genInvSphere(app)
            delete(app.InvSphere);
            % generate actual sphere
            [x, y, z] = sphere(50);
            s = surf(app.UIAxes, x * app.InvRad + app.InvX, y * app.InvRad + app.InvY, z * app.InvRad + app.InvZ);
            s.FaceAlpha = 0;
            s.EdgeColor = 'b';
            s.EdgeAlpha = 0.2;
            app.InvSphere = s;
        end
        
        % grayout certain options based on shape being drawn
        function grayOut(app)
            if app.ShapeSelect == "Sphere"
                set(app.HeightBox, "Enable", "off", "Editable", "off");
            elseif app.ShapeSelect == "Cylinder"
                set(app.HeightBox, "Enable", "on", "Editable", "on");
            end
            if app.ShapeSelect == "Sphere" || app.ShapeSelect == "Cylinder"
                % allow proper options
                set(app.ShapeRadBox, "Enable", "on", "Editable", "on");
                set(app.ShapeXBox, "Enable", "on", "Editable", "on");
                set(app.ShapeYBox, "Enable", "on", "Editable", "on");
                set(app.ShapeZBox, "Enable", "on", "Editable", "on");
                % disallow unused options
                set(app.ShowPointsBox, "Enable", "off");
                set(app.ARadBox, "Enable", "off", "Editable", "off");
                set(app.BRadBox, "Enable", "off", "Editable", "off");
                set(app.CRadBox, "Enable", "off", "Editable", "off");
                set(app.CustomNumBox, "Enable", "off", "Editable", "off");
                set(app.CurPointBox, "Enable", "off", "Editable", "off");
                set(app.CustomXBox, "Enable", "off", "Editable", "off");
                set(app.CustomYBox, "Enable", "off", "Editable", "off");
                set(app.CustomZBox, "Enable", "off", "Editable", "off");
                set(app.FuncDimenBox, "Enable", "off", "Editable", "off");
                set(app.FuncZBox, "Enable", "off", "Editable", "off");
            elseif app.ShapeSelect == "Ellipsoid"
                % allow proper options
                set(app.ShapeXBox, "Enable", "on", "Editable", "on");
                set(app.ShapeYBox, "Enable", "on", "Editable", "on");
                set(app.ShapeZBox, "Enable", "on", "Editable", "on");
                set(app.ARadBox, "Enable", "on", "Editable", "on");
                set(app.BRadBox, "Enable", "on", "Editable", "on");
                set(app.CRadBox, "Enable", "on", "Editable", "on");
                % disallow unused options
                set(app.ShowPointsBox, "Enable", "off");
                set(app.ShapeRadBox, "Enable", "off", "Editable", "off");
                set(app.CustomNumBox, "Enable", "off", "Editable", "off");
                set(app.CurPointBox, "Enable", "off", "Editable", "off");
                set(app.CustomXBox, "Enable", "off", "Editable", "off");
                set(app.CustomYBox, "Enable", "off", "Editable", "off");
                set(app.CustomZBox, "Enable", "off", "Editable", "off");
                set(app.HeightBox, "Enable", "off", "Editable", "off");
                set(app.FuncDimenBox, "Enable", "off", "Editable", "off");
                set(app.FuncZBox, "Enable", "off", "Editable", "off");
            elseif app.ShapeSelect == "Custom Points"
                % allow proper options
                set(app.ShowPointsBox, "Enable", "on");
                set(app.CustomNumBox, "Enable", "on", "Editable", "on");
                set(app.CurPointBox, "Enable", "on", "Editable", "on");
                set(app.CustomXBox, "Enable", "on", "Editable", "on");
                set(app.CustomYBox, "Enable", "on", "Editable", "on");
                set(app.CustomZBox, "Enable", "on", "Editable", "on");
                % disallow unused options
                set(app.ShapeRadBox, "Enable", "off", "Editable", "off");
                set(app.ShapeXBox, "Enable", "off", "Editable", "off");
                set(app.ShapeYBox, "Enable", "off", "Editable", "off");
                set(app.ShapeZBox, "Enable", "off", "Editable", "off");
                set(app.ARadBox, "Enable", "off", "Editable", "off");
                set(app.BRadBox, "Enable", "off", "Editable", "off");
                set(app.CRadBox, "Enable", "off", "Editable", "off");
                set(app.HeightBox, "Enable", "off", "Editable", "off");
                set(app.FuncDimenBox, "Enable", "off", "Editable", "off");
                set(app.FuncZBox, "Enable", "off", "Editable", "off");
            elseif app.ShapeSelect == "Custom Function"
                % allow proper options
                set(app.FuncDimenBox, "Enable", "on", "Editable", "on");
                set(app.FuncZBox, "Enable", "on", "Editable", "on");
                % disallow unused options
                set(app.ShapeRadBox, "Enable", "off", "Editable", "off");
                set(app.ShapeXBox, "Enable", "off", "Editable", "off");
                set(app.ShapeYBox, "Enable", "off", "Editable", "off");
                set(app.ShapeZBox, "Enable", "off", "Editable", "off");
                set(app.ARadBox, "Enable", "off", "Editable", "off");
                set(app.BRadBox, "Enable", "off", "Editable", "off");
                set(app.CRadBox, "Enable", "off", "Editable", "off");
                set(app.HeightBox, "Enable", "off", "Editable", "off");
                set(app.ShowPointsBox, "Enable", "off");
                set(app.CustomNumBox, "Enable", "off", "Editable", "off");
                set(app.CurPointBox, "Enable", "off", "Editable", "off");
                set(app.CustomXBox, "Enable", "off", "Editable", "off");
                set(app.CustomYBox, "Enable", "off", "Editable", "off");
                set(app.CustomZBox, "Enable", "off", "Editable", "off");
            end
        end
        
        % update shape coordinates
        function updateCoords(app)
            % if shape is sphere or cylinder, generate appropriate coordinates
            if app.ShapeSelect == "Sphere" || app.ShapeSelect == "Cylinder"
                genSphCyl(app);
                app.ShowPointsBox.Value = 0;
                app.ShowPlotPoints = 0;
                hidePoints(app);
            % if shape is ellipsoid, generate appropriate coordinates
            elseif app.ShapeSelect == "Ellipsoid"
                genEllipsoid(app);
                app.ShowPointsBox.Value = 0;
                app.ShowPlotPoints = 0;
                hidePoints(app);
            % if shape is defining custom points, perform appropriate setup
            elseif app.ShapeSelect == "Custom Points"
                setupCustom(app);
            % if shape is defining custom function, perform appropriate setup 
            elseif app.ShapeSelect == "Custom Functions"
                app.FuncDimen = app.FuncDimenBox.Value;
            end
        end
        
        % generate sphere or cylinder
        function genSphCyl(app)
            % gen coords based on sphere or cylinder
            if (app.ShapeSelect == "Sphere")
                [x, y, z] = sphere(app.Res);
                app.Coords = [x(:) * app.ShapeRad, y(:) * app.ShapeRad, z(:) * app.ShapeRad];
            else
                [x, y, z] = cylinder(app.ShapeRad, app.Res);
                app.Coords = [x(:), y(:), z(:) * app.Height];
            end
            % get number of points being plotted
            dimensions = size(app.Coords);
            numOfPoints = dimensions(1);
            app.NumOfPoints = numOfPoints;
            % iterate through coordinates and set center vals
            for num = 1:app.NumOfPoints
                app.Coords(num, 1) = app.Coords(num, 1) + app.ShapeX;
                app.Coords(num, 2) = app.Coords(num, 2) + app.ShapeY;
                app.Coords(num, 3) = app.Coords(num, 3) + app.ShapeZ;
            end
        end
        
        % generate ellipsoid
        function genEllipsoid(app)
            [x, y, z] = ellipsoid(app.ShapeX, app.ShapeY, app.ShapeZ, app.ARad, app.BRad, app.CRad, app.Res);
            app.Coords = [x(:), y(:), z(:)];
            % get number of points being plotted
            dimensions = size(app.Coords);
            numOfPoints = dimensions(1);
            app.NumOfPoints = numOfPoints;
        end
        
        % generate custom points
        function setupCustom(app)
            % reset location coords
            app.CustomXBox.Value = 0;
            app.CustomX = 0;
            app.CustomYBox.Value = 0;
            app.CustomY = 0;
            app.CustomZBox.Value = 0;
            app.CustomZ = 0;
            % generate array to store custom point coordinates
            app.NumOfPoints = app.CustomNum;
            app.Coords = zeros(app.NumOfPoints, 3);
            % populate array
            items = strings(1, app.NumOfPoints);
            itemsData = zeros(1, app.NumOfPoints);
            formatStr = "%d: (%d, %d, %d)";
            for num = 1:app.NumOfPoints
                items(num) = sprintf(formatStr, num, app.Coords(num, 1), app.Coords(num, 2), app.Coords(num, 3));
                itemsData(num) = num;
            end
            % update properties
            app.CurPointBox.Items = items;
            app.CurPointBox.ItemsData = itemsData;
            app.CurPoint = app.CurPointBox.Value;
        end
        
        % draw shape
        function drawShape(app)
            delete(app.Shape);
            % if points are supposed to be visible, show individual points
            if app.ShowPlotPoints == 1
                showPoints(app);
            end
            % plot actual surface based on coords
            bound = boundary(app.Coords, 0);
            s = trisurf(bound, app.Coords(: , 1), app.Coords(:, 2), app.Coords(:, 3), "FaceColor", "r", "FaceAlpha", 0.2, "EdgeAlpha", 0.5, "Parent", app.UIAxes);
            app.Shape = s;
        end
        
        % generate inverses
        function getInverses(app)
            numOfPoints = app.NumOfPoints;
            app.Inverses = zeros(numOfPoints, 3);
            pointNum = 1;
            % iterate through coordinates and find inverses
            while pointNum <= numOfPoints
                p = app.Coords(pointNum, :);
                o = [app.InvX, app.InvY, app.InvZ];
                inverse = getInv(app, p, o, app.InvRad);
                % if point is not at origin, note its inverse
                if ~isequal(inverse, 'd')
                    app.Inverses(pointNum, :) = inverse(:);
                    pointNum = pointNum + 1;
                % if point is at origin, remove it
                else
                    app.Coords(pointNum, :) = [];
                    app.Inverses(pointNum, :) = [];
                    numOfPoints = numOfPoints - 1;
                    % if point is visible, remove its marker as well
                    if app.ShowPlotPoints == 1
                        p = app.Points{pointNum};
                        delete(p);
                        app.Points(pointNum) = [];
                    end
                    continue;
                end
            end
            app.NumOfPoints = numOfPoints;
        end
        
        % individual inversion on point's coordinates
        function i = getInv(~, p, o, r)
            i = zeros(1, 3);
            % if current point located at origin, mark it to bevremoved
            if isequal(p, o)
                i = 'd';
            % otherwise, return inverse coords based on passed point and origin
            else
                for d = 1:3
                    i(d) = o(d) + ((r^2) * ((p(d) - o(d)))) / ((p(1) - o(1))^2 + (p(2) - o(2))^2 + (p(3) - o(3))^2);
                end
            end
        end
        
        % animate transition to inverse locations
        function animate(app)
            numOfPoints = app.NumOfPoints;
            steps = zeros(numOfPoints, 3);
            % get step info for each point
            for num = 1:numOfPoints
                inverse = app.Inverses(num, :);
                p = app.Coords(num, :);
                change = [(inverse(1) - p(1)) / app.Step, (inverse(2) - p(2)) / app.Step, (inverse(3) - p(3)) / app.Step];
                steps(num, :) = change;
            end
            % animate movement of each point to its inverse
            for t = 1:app.Step
                app.Coords = app.Coords + steps;
                % if markers are visible, move them as well
                if app.ShowPlotPoints == 1
                    for num = 1:app.NumOfPoints
                        p = app.Points{num};
                        p.XData = app.Coords(num, 1);
                        p.YData = app.Coords(num, 2);
                        p.ZData = app.Coords(num, 3);
                        drawnow limitrate;
                    end
                end
                % update surface reprsenting shape
                drawShape(app);
                pause(1 / app.Step);
            end
        end
        
        % show points
        function showPoints(app) 
            colors = ["b", "c", "g", "m", "k", "r", "y"];
            colorDimensions = size(colors);
            numOfColors = colorDimensions(2);
            % delete current points
            hidePoints(app);
            % plot new point markers from coords
            app.Points = cell(1, app.NumOfPoints);
            for num = 1:app.NumOfPoints
                p = plot3(app.UIAxes, app.Coords(num, 1), app.Coords(num, 2), app.Coords(num, 3), "r.");
                p.MarkerSize = 20;
                p.Color = colors(rem(num, numOfColors) + 1);
                app.Points{num} = p;
            end
        end
        
        % hide points
        function hidePoints(app)
            pointsDimensions = size(app.Points);
            tot = pointsDimensions(2);
            points = app.Points;
            % while visible markers remain, remove them
            while tot > 0
                p = points{:, tot};
                delete(p);
                tot = tot - 1;
            end
            drawnow limitrate;
        end
        
        % update custom "Current Point" dropdown menu
        function updateCurPointDropdown(app)
            num = app.CurPoint;
            items = strings(1, app.NumOfPoints);
            formatStr = "%d: (%d, %d, %d)";
            newStr = sprintf(formatStr, num, app.Coords(num, 1), app.Coords(num, 2), app.Coords(num, 3));
            % generate array of items with changed option
            for i = 1:app.NumOfPoints
                if i == num
                    items(i) = newStr;
                else
                    items(i) = app.CurPointBox.Items{i};
                end
            end
            app.CurPointBox.Items = items;
            % show point markers if applicable
            if app.ShowPlotPoints == 1
                showPoints(app);
            end
        end
        
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function onStart(app)
            % update inverse sphere properties
            app.InvRad = app.InvRadBox.Value;
            app.InvX = app.InvXBox.Value;
            app.InvY = app.InvYBox.Value;
            app.InvZ = app.InvZBox.Value;
            app.InvVis = app.InvVisBox.Value;
            
            % update shape properties
            app.ShapeSelect = app.ShapeSelectBox.Value;
            app.Height = app.HeightBox.Value;
            app.Res = app.ResSlider.Value;
            app.Step = app.StepSlider.Value;
            app.ShapeRad = app.ShapeRadBox.Value;
            app.ShapeX = app.ShapeXBox.Value;
            app.ShapeY = app.ShapeYBox.Value;
            app.ShapeZ = app.ShapeZBox.Value;
            app.ARad = app.ARadBox.Value;
            app.BRad = app.BRadBox.Value;
            app.CRad = app.CRadBox.Value;
            
            % update custom properties
            app.CustomNum = app.CustomNumBox.Value;
            
            % generate default inverse (unit) sphere and 
            genInvSphere(app);
            app.InvSphere.EdgeAlpha = 0.2;
            
            % get coordinates for unit sphere shape
            genSphCyl(app);
            
            % set properties for function
            app.FuncDimen = app.FuncDimenBox.Value;
            res = app.FuncDimen / 10;
            [x, y] = meshgrid((app.FuncDimen * -1):res:app.FuncDimen);
            app.FuncX = x;
            app.FuncY = y;
            
            % set properties of plot
            hold(app.UIAxes, "on");
            axis(app.UIAxes, "equal");
            grid(app.UIAxes, "on");
            
            % gray out unused shape options including non-working resolution slider
            grayOut(app);
            set(app.ResSlider, "Enable", "off");
        end

        % Value changed function: InvRadBox
        function updateInvRad(app, event)
            app.InvRad = app.InvRadBox.Value;
            genInvSphere(app);
        end

        % Value changed function: InvXBox
        function updateInvX(app, event)
            app.InvX = app.InvXBox.Value;
            genInvSphere(app);
        end

        % Value changed function: InvYBox
        function updateInvY(app, event)
            app.InvY = app.InvYBox.Value;
            genInvSphere(app);
        end

        % Value changed function: InvZBox
        function updateInvZ(app, event)
            app.InvZ = app.InvZBox.Value;
            genInvSphere(app);
        end

        % Value changed function: InvVisBox
        function updateInvVis(app, event)
            app.InvVis = app.InvVisBox.Value;
            % update visibility of inverse sphere based on checkbox
            if app.InvVis == 1
                app.InvSphere.EdgeAlpha = 0.2;
            else
                app.InvSphere.EdgeAlpha = 0;
            end
        end

        % Value changed function: ShapeSelectBox
        function updateShape(app, event)
            app.ShapeSelect = app.ShapeSelectBox.Value;
            grayOut(app);
            updateCoords(app);
        end

        % Value changed function: ShowPointsBox
        function updateShowPointsBox(app, event)
            app.ShowPlotPoints = app.ShowPointsBox.Value;
            % update point marker visibility based on checkbox
            if app.ShowPlotPoints == 0
                hidePoints(app);
            else
                showPoints(app);
            end
        end

        % Value changed function: ResSlider
        function updateRes(app, event)
            % NOTE: RESOLUTION SLIDER EXPERIMENTAL
            app.Res = app.ResSlider.Value;
            updateCoords(app);
        end

        % Value changed function: StepSlider
        function updateStep(app, event)
            app.Step = app.StepSlider.Value;
            updateCoords(app);
        end

        % Value changed function: ShapeXBox
        function updateShapeX(app, event)
            app.ShapeX = app.ShapeXBox.Value;
            updateCoords(app);
        end

        % Value changed function: ShapeYBox
        function updateShapeY(app, event)
            app.ShapeY = app.ShapeYBox.Value;
            updateCoords(app);
        end

        % Value changed function: ShapeZBox
        function updateShapeZ(app, event)
            app.ShapeZ = app.ShapeZBox.Value;
            updateCoords(app);
        end

        % Value changed function: ShapeRadBox
        function updateShapeRad(app, event)
            app.ShapeRad = app.ShapeRadBox.Value;
            updateCoords(app);
        end

        % Value changed function: HeightBox
        function updateHeight(app, event)
            app.Height = app.HeightBox.Value;
            updateCoords(app);
        end

        % Value changed function: ARadBox
        function updateARad(app, event)
            app.ARad = app.ARadBox.Value;
            updateCoords(app);
        end

        % Value changed function: BRadBox
        function updateBRad(app, event)
            app.BRad = app.BRadBox.Value;
            updateCoords(app);
        end

        % Value changed function: CRadBox
        function updateCRad(app, event)
            app.CRad = app.CRadBox.Value;
            updateCoords(app);
        end

        % Button pushed function: DrawShapeButton
        function DrawShape(app, event)
            % if shape is not custom set of points or function
            if app.ShapeSelect ~= "Custom Points" && app.ShapeSelect ~= "Custom Function"
                updateCoords(app);
            end
            drawShape(app);
        end

        % Button pushed function: InvButton
        function updateInv(app, event)
            getInverses(app);
            animate(app);
        end

        % Value changed function: CustomNumBox
        function updateCustomNum(app, event)
            app.CustomNum = app.CustomNumBox.Value;
            diff = app.CustomNum - app.NumOfPoints;
            % resize coord array based on change in number of points
            if (diff > 0)
                app.Coords = [app.Coords; zeros(diff, 3)];
                newItems = strings(1, diff);
                newItemsData = zeros(1, diff);
                formatStr = "%d: (%d, %d, %d)";
                % account for each new point being added
                for num = 1:diff
                    i = app.NumOfPoints + num;
                    newItems(num) = sprintf(formatStr, i, app.Coords(i, 1), app.Coords(i, 2), app.Coords(i, 3));
                    newItemsData(num) = (i);
                end
                % update properties
                app.CurPointBox.Items = [app.CurPointBox.Items, newItems];
                app.CurPointBox.ItemsData = [app.CurPointBox.ItemsData, newItemsData];
                app.NumOfPoints = app.CustomNum;
            elseif (diff < 0)
                % delete points from end
                for num = 1:(diff * -1)
                    app.Coords(app.NumOfPoints, :) = [];
                    app.CurPointBox.Items(app.NumOfPoints) = [];
                    app.CurPointBox.ItemsData(app.NumOfPoints) = [];
                    app.NumOfPoints = app.NumOfPoints - 1;
                end
            end
            % show points if applicable
            if app.ShowPlotPoints == 1
                showPoints(app);
            end
        end

        % Value changed function: CurPointBox
        function updateCurPoint(app, event)
            num = app.CurPointBox.Value;
            app.CurPoint = num;
            % update location coords based on current point
            app.CustomX = app.Coords(num, 1);
            app.CustomY = app.Coords(num, 2);
            app.CustomZ = app.Coords(num, 3);
            app.CustomXBox.Value = app.CustomX;
            app.CustomYBox.Value = app.CustomY;
            app.CustomZBox.Value = app.CustomZ;
            % show points if applicable
            if app.ShowPlotPoints == 1
                showPoints(app);
            end
        end

        % Value changed function: CustomXBox
        function updateCustomX(app, event)
            app.CustomX = app.CustomXBox.Value;
            num = app.CurPoint;
            app.Coords(num, 1) = app.CustomX;
            updateCurPointDropdown(app);
        end

        % Value changed function: CustomYBox
        function updateCustomY(app, event)
            app.CustomY = app.CustomYBox.Value;
            num = app.CurPoint;
            app.Coords(num, 2) = app.CustomY;
            updateCurPointDropdown(app);
        end

        % Value changed function: CustomZBox
        function updateCustomZ(app, event)
            app.CustomZ = app.CustomZBox.Value;
            num = app.CurPoint;
            app.Coords(num, 3) = app.CustomZ;
            updateCurPointDropdown(app);
        end

        % Value changed function: FuncDimenBox
        function updateFuncDimenBox(app, event)
            % NOTE: CUSTOM FUNCTIONS EXPERIMENTAL
             % generate regular meshgrid for x and y square forming base of function
            app.FuncDimen = app.FuncDimenBox.Value;
            res = app.FuncDimen / 10;
            [x, y] = meshgrid((app.FuncDimen * -1):res:app.FuncDimen);
            app.FuncX = x;
            app.FuncY = y;
            % get user passed formula
            funcStr = app.FuncZBox.Value;
            func = str2func(["@(x, y) (" + funcStr + ")"]);
            % apply user formula
            z = func(x, y);
            app.FuncZ = z;
            % update number of points being plotted
            dimensions = size(x);
            app.NumOfPoints = dimensions(1)^2;
            app.Coords = [x(:), y(:), z(:)];
        end

        % Value changed function: FuncZBox
        function updateFuncZ(app, event)
            % NOTE: CUSTOM FUNCTIONS EXPERIMENTAL
            % generate regular meshgrid for x and y square forming base of function
            app.FuncDimen = app.FuncDimenBox.Value;
            res = app.FuncDimen / 10;
            [x, y] = meshgrid((app.FuncDimen * -1):res:app.FuncDimen);
            app.FuncX = x;
            app.FuncY = y;
            % get user passed formula
            funcStr = app.FuncZBox.Value;
            func = str2func(["@(x, y) (" + funcStr + ")"]);
            % apply user formula
            z = func(x, y);
            app.FuncZ = z;
            % update number of points being plotted
            dimensions = size(x);
            app.NumOfPoints = dimensions(1)^2;
            app.Coords = [x(:), y(:), z(:)];
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SphericalInverterUIFigure and hide until all components are created
            app.SphericalInverterUIFigure = uifigure('Visible', 'off');
            app.SphericalInverterUIFigure.Position = [100 100 1010 581];
            app.SphericalInverterUIFigure.Name = 'Spherical Inverter';

            % Create UIAxes
            app.UIAxes = uiaxes(app.SphericalInverterUIFigure);
            title(app.UIAxes, '3D Plot')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [1.03807106598985 1 1];
            app.UIAxes.Position = [418 1 593 581];

            % Create InverseSpherePanel
            app.InverseSpherePanel = uipanel(app.SphericalInverterUIFigure);
            app.InverseSpherePanel.Title = 'Inverse Sphere';
            app.InverseSpherePanel.Position = [16 444 392 104];

            % Create RadiusEditFieldLabel
            app.RadiusEditFieldLabel = uilabel(app.InverseSpherePanel);
            app.RadiusEditFieldLabel.HorizontalAlignment = 'right';
            app.RadiusEditFieldLabel.Position = [5 55 43 22];
            app.RadiusEditFieldLabel.Text = 'Radius';

            % Create InvRadBox
            app.InvRadBox = uieditfield(app.InverseSpherePanel, 'numeric');
            app.InvRadBox.ValueChangedFcn = createCallbackFcn(app, @updateInvRad, true);
            app.InvRadBox.Position = [63 55 47 22];
            app.InvRadBox.Value = 1;

            % Create CenterLabel
            app.CenterLabel = uilabel(app.InverseSpherePanel);
            app.CenterLabel.Position = [10 28 42 22];
            app.CenterLabel.Text = 'Center';

            % Create XLabel
            app.XLabel = uilabel(app.InverseSpherePanel);
            app.XLabel.HorizontalAlignment = 'right';
            app.XLabel.Position = [68 28 25 22];
            app.XLabel.Text = 'X =';

            % Create InvXBox
            app.InvXBox = uieditfield(app.InverseSpherePanel, 'numeric');
            app.InvXBox.ValueChangedFcn = createCallbackFcn(app, @updateInvX, true);
            app.InvXBox.Position = [108 28 47 22];

            % Create YLabel
            app.YLabel = uilabel(app.InverseSpherePanel);
            app.YLabel.HorizontalAlignment = 'right';
            app.YLabel.Position = [164 28 25 22];
            app.YLabel.Text = 'Y =';

            % Create InvYBox
            app.InvYBox = uieditfield(app.InverseSpherePanel, 'numeric');
            app.InvYBox.ValueChangedFcn = createCallbackFcn(app, @updateInvY, true);
            app.InvYBox.Position = [204 28 47 22];

            % Create ZLabel
            app.ZLabel = uilabel(app.InverseSpherePanel);
            app.ZLabel.HorizontalAlignment = 'right';
            app.ZLabel.Position = [270 28 25 22];
            app.ZLabel.Text = 'Z =';

            % Create InvZBox
            app.InvZBox = uieditfield(app.InverseSpherePanel, 'numeric');
            app.InvZBox.ValueChangedFcn = createCallbackFcn(app, @updateInvZ, true);
            app.InvZBox.Position = [310 28 47 22];

            % Create InvVisBox
            app.InvVisBox = uicheckbox(app.InverseSpherePanel);
            app.InvVisBox.ValueChangedFcn = createCallbackFcn(app, @updateInvVis, true);
            app.InvVisBox.Text = 'Visible';
            app.InvVisBox.Position = [12 4 57 22];
            app.InvVisBox.Value = true;

            % Create SphericalInverterLabel
            app.SphericalInverterLabel = uilabel(app.SphericalInverterUIFigure);
            app.SphericalInverterLabel.FontSize = 20;
            app.SphericalInverterLabel.FontWeight = 'bold';
            app.SphericalInverterLabel.Position = [16 552 174 24];
            app.SphericalInverterLabel.Text = 'Spherical Inverter';

            % Create DataPanel
            app.DataPanel = uipanel(app.SphericalInverterUIFigure);
            app.DataPanel.Title = 'Data';
            app.DataPanel.Position = [16 34 392 412];

            % Create ResolutionSliderLabel
            app.ResolutionSliderLabel = uilabel(app.DataPanel);
            app.ResolutionSliderLabel.HorizontalAlignment = 'right';
            app.ResolutionSliderLabel.Position = [5 339 62 22];
            app.ResolutionSliderLabel.Text = 'Resolution';

            % Create ResSlider
            app.ResSlider = uislider(app.DataPanel);
            app.ResSlider.Limits = [10 30];
            app.ResSlider.MajorTicks = [10 20 30];
            app.ResSlider.ValueChangedFcn = createCallbackFcn(app, @updateRes, true);
            app.ResSlider.MinorTicks = [10 20 30];
            app.ResSlider.Tooltip = {'Disabled temporarily'};
            app.ResSlider.Position = [88 348 150 3];
            app.ResSlider.Value = 20;

            % Create StepsSliderLabel
            app.StepsSliderLabel = uilabel(app.DataPanel);
            app.StepsSliderLabel.HorizontalAlignment = 'right';
            app.StepsSliderLabel.Position = [30 297 36 22];
            app.StepsSliderLabel.Text = 'Steps';

            % Create StepSlider
            app.StepSlider = uislider(app.DataPanel);
            app.StepSlider.Limits = [1 500];
            app.StepSlider.ValueChangedFcn = createCallbackFcn(app, @updateStep, true);
            app.StepSlider.Position = [87 306 150 3];
            app.StepSlider.Value = 100;

            % Create ShapeLabel
            app.ShapeLabel = uilabel(app.DataPanel);
            app.ShapeLabel.Position = [10 242 42 22];
            app.ShapeLabel.Text = 'Center';

            % Create XEditField_2Label
            app.XEditField_2Label = uilabel(app.DataPanel);
            app.XEditField_2Label.HorizontalAlignment = 'right';
            app.XEditField_2Label.Position = [68 242 25 22];
            app.XEditField_2Label.Text = 'X =';

            % Create ShapeXBox
            app.ShapeXBox = uieditfield(app.DataPanel, 'numeric');
            app.ShapeXBox.ValueChangedFcn = createCallbackFcn(app, @updateShapeX, true);
            app.ShapeXBox.Position = [108 242 47 22];

            % Create YEditField_2Label
            app.YEditField_2Label = uilabel(app.DataPanel);
            app.YEditField_2Label.HorizontalAlignment = 'right';
            app.YEditField_2Label.Position = [164 242 25 22];
            app.YEditField_2Label.Text = 'Y =';

            % Create ShapeYBox
            app.ShapeYBox = uieditfield(app.DataPanel, 'numeric');
            app.ShapeYBox.ValueChangedFcn = createCallbackFcn(app, @updateShapeY, true);
            app.ShapeYBox.Position = [204 242 47 22];

            % Create ZEditField_2Label
            app.ZEditField_2Label = uilabel(app.DataPanel);
            app.ZEditField_2Label.HorizontalAlignment = 'right';
            app.ZEditField_2Label.Position = [270 242 25 22];
            app.ZEditField_2Label.Text = 'Z =';

            % Create ShapeZBox
            app.ShapeZBox = uieditfield(app.DataPanel, 'numeric');
            app.ShapeZBox.ValueChangedFcn = createCallbackFcn(app, @updateShapeZ, true);
            app.ShapeZBox.Position = [310 242 47 22];

            % Create RadiusEditField_2Label
            app.RadiusEditField_2Label = uilabel(app.DataPanel);
            app.RadiusEditField_2Label.HorizontalAlignment = 'right';
            app.RadiusEditField_2Label.Position = [5 211 43 22];
            app.RadiusEditField_2Label.Text = 'Radius';

            % Create ShapeRadBox
            app.ShapeRadBox = uieditfield(app.DataPanel, 'numeric');
            app.ShapeRadBox.ValueChangedFcn = createCallbackFcn(app, @updateShapeRad, true);
            app.ShapeRadBox.Position = [63 211 47 22];
            app.ShapeRadBox.Value = 1;

            % Create AEditFieldLabel
            app.AEditFieldLabel = uilabel(app.DataPanel);
            app.AEditFieldLabel.HorizontalAlignment = 'right';
            app.AEditFieldLabel.Position = [4 180 25 22];
            app.AEditFieldLabel.Text = 'A =';

            % Create ARadBox
            app.ARadBox = uieditfield(app.DataPanel, 'numeric');
            app.ARadBox.ValueChangedFcn = createCallbackFcn(app, @updateARad, true);
            app.ARadBox.Position = [44 180 47 22];
            app.ARadBox.Value = 1;

            % Create BEditFieldLabel
            app.BEditFieldLabel = uilabel(app.DataPanel);
            app.BEditFieldLabel.HorizontalAlignment = 'right';
            app.BEditFieldLabel.Position = [100 180 25 22];
            app.BEditFieldLabel.Text = 'B =';

            % Create BRadBox
            app.BRadBox = uieditfield(app.DataPanel, 'numeric');
            app.BRadBox.ValueChangedFcn = createCallbackFcn(app, @updateBRad, true);
            app.BRadBox.Position = [140 180 47 22];
            app.BRadBox.Value = 1;

            % Create CEditFieldLabel
            app.CEditFieldLabel = uilabel(app.DataPanel);
            app.CEditFieldLabel.HorizontalAlignment = 'right';
            app.CEditFieldLabel.Position = [206 180 25 22];
            app.CEditFieldLabel.Text = 'C =';

            % Create CRadBox
            app.CRadBox = uieditfield(app.DataPanel, 'numeric');
            app.CRadBox.ValueChangedFcn = createCallbackFcn(app, @updateCRad, true);
            app.CRadBox.Position = [246 180 47 22];
            app.CRadBox.Value = 1;

            % Create DrawShapeButton
            app.DrawShapeButton = uibutton(app.DataPanel, 'push');
            app.DrawShapeButton.ButtonPushedFcn = createCallbackFcn(app, @DrawShape, true);
            app.DrawShapeButton.Position = [5 6 100 22];
            app.DrawShapeButton.Text = 'Draw Shape';

            % Create ShapeSelectionDropDownLabel
            app.ShapeSelectionDropDownLabel = uilabel(app.DataPanel);
            app.ShapeSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.ShapeSelectionDropDownLabel.Position = [5 364 93 22];
            app.ShapeSelectionDropDownLabel.Text = 'Shape Selection';

            % Create ShapeSelectBox
            app.ShapeSelectBox = uidropdown(app.DataPanel);
            app.ShapeSelectBox.Items = {'Sphere', 'Cylinder', 'Ellipsoid', 'Custom Points', 'Custom Function'};
            app.ShapeSelectBox.ValueChangedFcn = createCallbackFcn(app, @updateShape, true);
            app.ShapeSelectBox.Position = [112 364 159 22];
            app.ShapeSelectBox.Value = 'Sphere';

            % Create NumberofPointsSpinnerLabel
            app.NumberofPointsSpinnerLabel = uilabel(app.DataPanel);
            app.NumberofPointsSpinnerLabel.HorizontalAlignment = 'right';
            app.NumberofPointsSpinnerLabel.Position = [4 124 98 22];
            app.NumberofPointsSpinnerLabel.Text = 'Number of Points';

            % Create CustomNumBox
            app.CustomNumBox = uispinner(app.DataPanel);
            app.CustomNumBox.Limits = [1 Inf];
            app.CustomNumBox.ValueChangedFcn = createCallbackFcn(app, @updateCustomNum, true);
            app.CustomNumBox.Position = [117 124 49 22];
            app.CustomNumBox.Value = 1;

            % Create CurrentPointDropDownLabel
            app.CurrentPointDropDownLabel = uilabel(app.DataPanel);
            app.CurrentPointDropDownLabel.HorizontalAlignment = 'right';
            app.CurrentPointDropDownLabel.Position = [169 124 76 22];
            app.CurrentPointDropDownLabel.Text = 'Current Point';

            % Create CurPointBox
            app.CurPointBox = uidropdown(app.DataPanel);
            app.CurPointBox.Items = {'1'};
            app.CurPointBox.ValueChangedFcn = createCallbackFcn(app, @updateCurPoint, true);
            app.CurPointBox.Position = [259 124 124 22];
            app.CurPointBox.Value = '1';

            % Create CustomLabel
            app.CustomLabel = uilabel(app.DataPanel);
            app.CustomLabel.Position = [10 92 51 22];
            app.CustomLabel.Text = 'Location';

            % Create XEditField_2Label_2
            app.XEditField_2Label_2 = uilabel(app.DataPanel);
            app.XEditField_2Label_2.HorizontalAlignment = 'right';
            app.XEditField_2Label_2.Position = [68 92 25 22];
            app.XEditField_2Label_2.Text = 'X =';

            % Create CustomXBox
            app.CustomXBox = uieditfield(app.DataPanel, 'numeric');
            app.CustomXBox.ValueChangedFcn = createCallbackFcn(app, @updateCustomX, true);
            app.CustomXBox.Position = [108 92 47 22];

            % Create YEditField_2Label_2
            app.YEditField_2Label_2 = uilabel(app.DataPanel);
            app.YEditField_2Label_2.HorizontalAlignment = 'right';
            app.YEditField_2Label_2.Position = [164 92 25 22];
            app.YEditField_2Label_2.Text = 'Y =';

            % Create CustomYBox
            app.CustomYBox = uieditfield(app.DataPanel, 'numeric');
            app.CustomYBox.ValueChangedFcn = createCallbackFcn(app, @updateCustomY, true);
            app.CustomYBox.Position = [204 92 47 22];

            % Create ZEditField_2Label_2
            app.ZEditField_2Label_2 = uilabel(app.DataPanel);
            app.ZEditField_2Label_2.HorizontalAlignment = 'right';
            app.ZEditField_2Label_2.Position = [270 92 25 22];
            app.ZEditField_2Label_2.Text = 'Z =';

            % Create CustomZBox
            app.CustomZBox = uieditfield(app.DataPanel, 'numeric');
            app.CustomZBox.ValueChangedFcn = createCallbackFcn(app, @updateCustomZ, true);
            app.CustomZBox.Position = [310 92 47 22];

            % Create CustomDisclaim
            app.CustomDisclaim = uilabel(app.DataPanel);
            app.CustomDisclaim.FontAngle = 'italic';
            app.CustomDisclaim.Position = [10 150 383 22];
            app.CustomDisclaim.Text = 'For Custom Points at least 5 distinct points required for visible surface';

            % Create ShowPointsBox
            app.ShowPointsBox = uicheckbox(app.DataPanel);
            app.ShowPointsBox.ValueChangedFcn = createCallbackFcn(app, @updateShowPointsBox, true);
            app.ShowPointsBox.Text = 'Show Points';
            app.ShowPointsBox.Position = [289 364 89 22];

            % Create HeightLabel
            app.HeightLabel = uilabel(app.DataPanel);
            app.HeightLabel.HorizontalAlignment = 'right';
            app.HeightLabel.Position = [126 211 40 22];
            app.HeightLabel.Text = 'Height';

            % Create HeightBox
            app.HeightBox = uieditfield(app.DataPanel, 'numeric');
            app.HeightBox.ValueChangedFcn = createCallbackFcn(app, @updateHeight, true);
            app.HeightBox.Position = [181 211 47 22];
            app.HeightBox.Value = 1;

            % Create DimensionLabel
            app.DimensionLabel = uilabel(app.DataPanel);
            app.DimensionLabel.HorizontalAlignment = 'right';
            app.DimensionLabel.Position = [5 62 62 22];
            app.DimensionLabel.Text = 'Dimension';

            % Create FuncDimenBox
            app.FuncDimenBox = uieditfield(app.DataPanel, 'numeric');
            app.FuncDimenBox.Limits = [0 Inf];
            app.FuncDimenBox.ValueChangedFcn = createCallbackFcn(app, @updateFuncDimenBox, true);
            app.FuncDimenBox.Position = [82 62 47 22];
            app.FuncDimenBox.Value = 1;

            % Create ZEditFieldLabel
            app.ZEditFieldLabel = uilabel(app.DataPanel);
            app.ZEditFieldLabel.HorizontalAlignment = 'right';
            app.ZEditFieldLabel.Position = [71 33 25 22];
            app.ZEditFieldLabel.Text = 'Z =';

            % Create FuncZBox
            app.FuncZBox = uieditfield(app.DataPanel, 'text');
            app.FuncZBox.ValueChangedFcn = createCallbackFcn(app, @updateFuncZ, true);
            app.FuncZBox.Position = [111 33 200 22];
            app.FuncZBox.Value = 'x*0+y*0';

            % Create FuncLabel
            app.FuncLabel = uilabel(app.DataPanel);
            app.FuncLabel.Position = [10 33 52 22];
            app.FuncLabel.Text = 'Function';

            % Create InvButton
            app.InvButton = uibutton(app.SphericalInverterUIFigure, 'push');
            app.InvButton.ButtonPushedFcn = createCallbackFcn(app, @updateInv, true);
            app.InvButton.Position = [167 6 100 22];
            app.InvButton.Text = 'Invert';

            % Show the figure after all components are created
            app.SphericalInverterUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SphericalInverter

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SphericalInverterUIFigure)

            % Execute the startup function
            runStartupFcn(app, @onStart)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SphericalInverterUIFigure)
        end
    end
end
