% === encoding in UTF-8 ===

classdef functions
    methods(Static)
        % function constructor
        function res = equ_constructor(a)
            res = @(x) a .* x ./ (1 + (a - 1) .* x);
        end

        function res = setter(max, min, msg,des,desarg)
            res = input(msg);
            while true
                if(res >= min && max >= res)
                    break;
                else
                    clc
                    fprintf("input vlaue out of range\nvlaue should be %d ~ %d\n",min,max)
                    if(nargin > 3)
                        des(desarg)
                    end
                    res = input(msg);
                end
            end
        end

        function res = line_constructor(x1,y1,x2,y2)
            slop = (y1-y2) / (x1-x2);
            b = y1 - slop * x1;
            res = @(x) slop * x + b;
        end

        function res = solve(equ1, equ2)
            res = fzero(@(x) equ1(x) - equ2(x), [0,1]);
        end

        function res = plot_T(equ,feed_equ,feed_status,a_in,equt,equb,top,bottom)
            L = @(x) top;
            px = functions.solve(L,equ);
            plot([top,px],[top,top])
            i_ = 1;
            in_plate = 0;
            flag = 0;
            py_L = -1;
            while px > bottom
                if(flag == 0)
                    px1 = px;
                    py = equt(px)
                    L_ = @(~) py; %--
                    px = functions.solve(L_,equ);
                    try
                        if (feed_status == 1)
                            if(px < a_in)
                                flag = 1;
                            end
                        elseif(feed_status == 2)
                            if(py < a_in)
                                if(in_plate == 0)
                                    in_plate = i_;
                                end
                                py = equb(px1)
                                L_ = @(~) py; %--
                                px = functions.solve(L_,equ);
                                flag = 1;
                            end
                        end
                        fzero(@(x) L_(x) - feed_equ(x), [px,px1]);
                        flag = 1;
                    catch
                    end
                else
                    if(in_plate == 0)
                        in_plate = i_;
                    end
                    px1 = px;
                    py = equb(px)
                    L_ = @(~) py; %--
                    px = functions.solve(L_,equ);
                    line = plot([px1,px],[py,py]);
                    line.Color = [0,0,0];
                end
                line = plot([px1,px],[py,py]);
                line.Color = [0,0,0];
                if (top > 0)
                    line = plot([px1,px1],[py,top]);
                    line.Color = [0.4,0.4,0.4];
                    top = -1;
                end
                if(py_L > -1)
                    line = plot([px1,px1],[py,py_L]);
                    line.Color = [0.4,0.4,0.4];
                end
                py_L = py;
                i_ = i_ + 1;
                
            end
            res = [i_,in_plate];
        end
    end
end

