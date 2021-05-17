classdef EStop < handle
    properties (SetAccess = private)
        EStopSub
        RMRCI RMRC.Interface
        debug logical = false;
        timerObject timer
        timerPeriod = 0.1;
    end
    methods (Access = public)
        function self = EStop(debug,RMRCI)
            self.EStopSub = rossubscriber('/pushed');
            self.RMRCI = RMRCI;
            self.TimerSetup()
            if ~isempty(debug)
                self.debug = debug;
            end
        end
        function delete(self)
            try
                stop(self.timerObject);
                delete(self.timerObject);
            end
        end
        function msgData = UpdateEStop(self)
            msg = receive(self.EStopSub,0.1);
            msgData = msg(1).Data;
            if msgData == 1
                self.RMRCI.Stop();
            end
        end
    end
    methods (Access = private)
        function TimerSetup(self)
            t = timer;
            t.Name = 'EStop ROS Refresh Timer';
            t.TimerFcn = @(~, ~) self.TimerUpdate();
            t.Period = self.timerPeriod;
            t.ExecutionMode = 'fixedDelay';
            self.timerObject = t;
            start(self.timerObject);
        end
        function TimerUpdate(self)
            self.UpdateARTags();
        end
    end
end