% =================
% encoding in UTF-8
% Licence MIT
% Author Jaycheng
% =================
% INIT
close all
clear
clc
version = ENV.version;
act = ENV.act;
% =================
fprintf("===========================================\nNOTE:\nencoding in UTF-8\nyour MATLAB should support UTF-8 to display unicode symbol\n===========================================\n")
fprintf("version: %s\n",version)
input("press enter to continue...")
clc


% =============user data
flag = 2;
while flag == 2

    a_in = functions.setter(100,1,"set feed A (%): ");

    clc

    a_top = functions.setter(100,a_in,"set Top A (%): ");

    clc

    a_bottom = functions.setter(a_in,0,"set bottom A (%): ");

    clc

    alpha_ = functions.setter(1e10,0,"set alpha: ");

    clc

    de = @(~)fprintf("===================\n(1)Saturated liquid\n(2)saturated gas\n(3)Half [50%% liquid |50%% gas](待更新)\n===================\n");
    de([]);
    feed_status = functions.setter(2,1,"set status: ",de,[]);

    clc

    de = @(~)fprintf("===================\nRD_min x <Rate> = RD\n===================\n");
    de([]);
    rd_rate = functions.setter(1e10,0,"set RD rate: ",de,[]);

    clc

    de = @(a)fprintf("===================\nsetting pre view\n===================\n             ├─├──────> A:%g %% | B:%g %%\nA:%s%% | B:%s%%│ │ \n   ─────────>│ │ \n             │ │ \n             └─└──────> A:%g %% | B:%g %%\n",a(1,1),a(1,2),a(1,3:4),a(1,5:6),a(1,7),a(1,8));
    a_in_d = round(a_in);
    if (a_in_d < 10)
        a_in_d = "0" + num2str(a_in_d,1);
    else
        a_in_d = num2str(a_in_d,2);
    end

    b_in_d = 100 - round(a_in);
    if (b_in_d < 10)
        b_in_d = "0" + num2str(b_in_d,1);
    else
        b_in_d = num2str(b_in_d,2);
    end

    de([a_top,100-a_top,a_in_d,b_in_d,a_bottom,100-a_bottom])
    flag = functions.setter(2,1,"input \n1 to accept \n2 to reset\n",de,[a_top,100-a_top,a_in_d,b_in_d,a_bottom,100-a_bottom]);
    clc
end
disp("generating...")
% =============
if (feed_status == 1)
    feed_equ = @(~) -1;
elseif(feed_status == 2)
    feed_equ = @(~) a_in / 100;
else
    feed_equ = @(x) -1 * x + (2 - a_in / 100);
end

% ============
fig = figure();
fig.Position = [100, 100, 800, 800];
hold on
grid on

x = 0:(1/act):1;

slash = plot([0,1], [0,1]); %slash
slash.Color = [0,0,0];

equ = functions.equ_constructor(alpha_);
y = equ(x);
plot(x,y)


% feed line
fy = feed_equ(0);
if ( fy == -1)
    feedp = [a_in/100,1];
elseif(fy > 1)
    feedp = [1 - feed_equ(0),1];
else
    feedp = [0,feed_equ(0)];
end
plot([a_in/100,feedp(1,1)],[a_in/100,feedp(1,2)])

% 精餾段 rdmin
if(feed_status == 1)
    x_intersect = a_in/100;
else
    x_intersect = functions.solve(equ,feed_equ);
end
y_intersect = equ(x_intersect);

p_ = functions.line_constructor(x_intersect,y_intersect,a_top/100,a_top/100);
rdmin = p_(0);
rdmin_line = plot([a_top/100,0],[a_top/100,rdmin]);
rdmin_line.LineStyle = "-.";

% ===========rd
rdmin = (a_top/100)/rdmin -1;
rd = rdmin * rd_rate;
rd = a_top/100/(rd + 1);

p_ = functions.line_constructor(0,rd,a_top/100,a_top/100);
plot([a_top/100,0],[a_top/100,p_(0)])

% =============
y_intersect = -1;
if (feed_status == 1)
    y_intersect = p_(a_in/100);
else
    x_intersect = functions.solve(p_,feed_equ);
end
if(y_intersect == -1)
    plot([a_bottom/100,x_intersect],[a_bottom/100,p_(x_intersect)])
else
    plot([a_bottom/100,x_intersect],[a_bottom/100,y_intersect])
end

% =============T

plates = functions.plot_T(equ,feed_equ,feed_status,a_in/100,p_,functions.line_constructor(a_bottom/100,a_bottom/100,x_intersect,p_(x_intersect)),a_top/100,a_bottom/100);
clc
fprintf("=======================\n精餾塔理想板數: %d 板\n進料板為第 %d 板\n=======================\n",plates(1),plates(2))
data = {
    ["x",x];
    ["y",y];
};
saveas(fig,"./output/design.png","png")
writecell(data,"./output/data.xlsx","Sheet","data")



