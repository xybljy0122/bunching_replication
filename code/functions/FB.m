function [dx_hat,alpha_hat] = FB(X,X0,x_l,x_min,x_max,degree,friction,noise,fig)

%% simulate data (for checking the code, use test.m)


G=10^4; % the finest grid to record distribution 
edge = linspace(x_min,x_max,G+1)';
grid = edge(1:end-1);
f = histcounts(X,edge,'Normalization','probability')';% conditional probability at excluded range

if X0=='NA'
    N=size(X,1);
    J=round(N/10); % J bins, with 10 obs in each bin
    [y,x] = histcounts(X,J,'Normalization','probability');% unconditional probability for the whole sample
    x = x(1:end-1);
    w=(x>=x_min&x<=x_max);
    p = polyfit([x(~w)],[y(~w)],degree);%fit a polynomial function for the whole sample
    f0= polyval(p,grid)./sum(polyval(p,grid));% conditional probability at excluded range
else 
    N=size(X0,1);
    J=round(N/10); % J bins, with 10 obs in each bin
    [y,x] = histcounts(X0,J,'Normalization','probability');% unconditional probability for the whole sample
    x = x(1:end-1);
    p = polyfit(x,y,degree);%fit a polynomial function for the whole sample
    f0=histcounts(X0,edge,'Normalization','probability')';% conditional probability at excluded range
end

A=trapz(grid,cumsum(f)-cumsum(f0)); % unit is probability: (number of observations in bin / total number of observations)
% f0_x_l = polyval(p,x_l)./sum(polyval(p,grid))./(grid(2)-grid(1)); % probability per unit of x
f0_x_l = 1/(x_max-x_min); %  probability per unit of x, assuming the distribution is locally uniform

if friction==0
dx_hat= sqrt((2 * A) / f0_x_l );
alpha_hat=0;
end

if friction==1&&noise==0 % estimate alpha without measurement error
dx_hat= sqrt((2 * A) / f0_x_l );
dF_alpha = interp1q(grid,cumsum(f),x_l+dx_hat)-interp1q(grid,cumsum(f),x_l);
dF0_alpha = interp1q(grid,cumsum(f0),x_l+dx_hat)-interp1q(grid,cumsum(f0),x_l);
alpha_hat =dF_alpha/dF0_alpha;
dx_hat= sqrt((2 * A) / ((1-alpha_hat)*f0_x_l)) ;
end

if friction==1&&noise==1 % estimate alpha with measurement error
F_x_l = interp1q(grid,cumsum(f),x_l);
alpha_vec = linspace(0,0.99,100)';
dx_vec =  sqrt((2*A)./ ((1-alpha_vec) * f0_x_l));
alpha_vec2 =   2*(interp1q(grid,cumsum(f),x_l+dx_vec)- F_x_l)./(f0_x_l *dx_vec) -1;
[~, index_Values] =  min( abs( alpha_vec - alpha_vec2 ));
alpha_hat=alpha_vec(index_Values);
dx_hat =  sqrt((2*A)./ ((1-alpha_hat) * f0_x_l));

%% iteration method (comment out if not stable)
% F_x_l = interp1q(grid,cumsum(f),x_l);
% error=1;ii=1;
% while error>10^-6&&ii<10^3
% dx_hat =  sqrt((2*A)./ ((1-alpha_hat) * f0_x_l));
% alpha_hat_new =   2*(interp1q(grid,cumsum(f),x_l+dx_hat)- F_x_l)./(f0_x_l *dx_hat) -1; %one more interation
% error=abs(alpha_hat_new-alpha_hat);
% alpha_hat=alpha_hat_new
% ii=ii+1;

end

if fig==1
figure;
hold on;
plot(grid,cumsum(f),grid,cumsum(f0)); 
hold off;
end

end
 

 
