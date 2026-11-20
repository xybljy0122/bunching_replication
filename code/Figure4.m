%% Set paths
clear;clc;close all
addpath('./functions')
Figures = ('../output');
i=1;

%% Set Model Functions and Parameters

% Global parameters
global beta Abar e bnum tau muz sigz
beta    = 33; % Semi-elasticity of demand
Abar    = 10; % Asset threshold
e       = exp(1);
bnum    = 1;
tau     = 0;

muz    = 3;
sigs   = 0.05;
sigz   = 0.7;
qd = log(Abar);
q_up   = @(k, beta) log(z_upperbar(1,tau,k,beta,Abar, []))-1;
fzero  = @(x,sig)  (sigz*sqrt(2*pi))^-1 * sqrt(sigz^2/(sig^2+sigz^2)) * exp(-0.5 .* (1+x-muz).^2/(sig^2+sigz^2));

options_fsolve = optimoptions('fsolve','Display','off','FunctionTolerance',1e-12);
zlb = @(b) Abar*e./b;
zub  = @(b,tau,k) fsolve( @(x)( 1e3*(Abar/beta) .* (log(x) - log(Abar./b))        ...
                                    - 1e3*b.*x./( beta*exp(1+beta*tau) ) + 1e3*k ),2e3*zlb(b), options_fsolve);

q   = @(z,b,tau,k) ~(tau == 0 & k == 0) .* ((z<=zlb(b))                   .* z./e               + ...
                  (z> zlb(b)).*(z<=zub(b,tau,k)) .* Abar./b            + ...
                  (z> zub(b,tau,k))             .* z./exp(1+beta*tau)) + ...
                  (tau == 0 & k == 0) .* z./e;

a  = @(z,b,tau,k) b.*q(z,b,tau,k);
Pi = @(z,b,tau,k) ~(tau == 0 && k == 0) .* ...
                   ( ...
                   (z<zlb(b)) .* b.*z./(beta*e) + ...
                  (z>= zlb(b)).*(z<=zub(b,tau,k)) .* Abar./beta.*(log(z)-log(Abar./b)) +...
                  (z> zub(b,tau,k)) .* (b.*z./(beta*exp(1+beta*tau))-k) ...
                  ) + ...
                  (tau == 0 && k == 0) .* b.*z./(beta*e) ;

% Functions
Phi  = @(z) normcdf(z);
phi  = @(z) normpdf(z);




%% Figure (theoretical distribution):
alpha = 0.0;
N     = 5e7;
sigs  = 0.05;
myk   = 0.01;
q  = @(z,b,tau,k) ~(tau == 0 & k == 0) .* ((z<=zlb(b))                   .* z./e               + ...
                  (z> zlb(b)).*(z<=z_upperbar(b,tau,k,beta,Abar, [])) .* Abar./b            + ...
                  (z> z_upperbar(b,tau,k,beta,Abar, []))             .* z./exp(1+beta*tau)) + ...
                  (tau == 0 & k == 0) .* z./e;
a_func  = @(z,b,tau,k) b.*q(z,b,tau,k);

z  = exp(muz + sigz * randn([2*N,1])); 
shocku  = randn([2*N,1]);
dontadj = rand([N,1]) <= alpha; % 1 an

apre = a_func(z(1:N),bnum,tau, 0) .*  exp(sigs*shocku(1:N));

z_post      = z((N+1):(2*N));
shocku_post = shocku((N+1):(2*N));

apost        = a_func(z_post,bnum,tau, myk) .* exp(sigs * shocku_post);
apost(dontadj)        = a_func(z_post(dontadj),bnum,tau, 0) .* exp(sigs * shocku_post(dontadj)) ; % For the ones that don't adjust, it's like k was 0

apost_zerosig = a_func(z_post,bnum,tau, myk);
apost_zerosig(dontadj)        = a_func(z_post(dontadj),bnum,tau, 0) ; % For the ones that don't adjust, it's like k was 0


apost_sub = log(apost);
apost_zerosig_sub = log(apost_zerosig);

if false 
    qu = qd
    qd 
    sig = 0;
    alpha = 0.5
    a = 2.34
    
    F1(2.34, qd, qd, 0)
    F2(2.34, qd, qd, 0, alpha)
    F3(2.34, qd, qd, 0, alpha)
    F(2.34, qd, qd, 0, alpha)
end

i = i + 1;

x     = linspace(log(8),log(16),250)';
F_all = zeros(length(x),4);
for i = 1:length(x)
    F_all(i,1) = CDFwithFriction(x(i),qd,qd,0, alpha);
    F_all(i,2) = CDFwithFriction(x(i),q_up(0.01,beta),qd,0, alpha);
    F_all(i,3) = CDFwithFriction(x(i), q_up(0.01,beta), qd, sigs, alpha);
    F_all(i,4) = CDFwithFriction(x(i), q_up(0.01,beta), qd, 0, 0);
end

% These define the placement and size of the brace
myx = log(Abar - 0.1) ;
y1 = CDFwithFriction(qd+1e-9,q_up(0.01,beta),qd,0,alpha);
y2 = CDFwithFriction(qd+1e-9,q_up(0.01,beta),qd,0, 0);
width = 0.01;
% Make some x-data and y-data
line_x = myx  - [0, 0.5, 0.5, 1, 0.5, 0.5, 0]*width;
line_y = y1 + [0, 0.02, 0.48, 0.5, 0.52, 0.98, 1]*(y2-y1);
% Draw the brace and some text, too, for fun.


rng(1);
myN       = 500;
myz_post       = exp(muz + sigz * randn([myN,1])); 
myshocku  = randn([myN,1]);
myapost   = sort(a_func(myz_post,bnum,tau, myk) .* exp(sigs * myshocku));
myapost_counter   = sort(a_func(myz_post,bnum,0, 0) .* exp(sigs * myshocku));
mydontadj = rand([myN,1]) <= alpha; % 1 an
myapost(mydontadj) = myapost_counter(mydontadj);


%%
% CDFs

figure;
hold on;
plot(x,F_all(:,2),'-','LineWidth',2,'color',[0.8500, 0.3250, 0.0980])
plot(x,F_all(:,1) ,'--','LineWidth',2, 'color', [0, 0.4470, 0.7410])
plot([qd,q_up(0.01,beta);qd,q_up(0.01,beta)],[ylim;ylim]','--k')
line([log(Abar),q_up(0.01,beta)],[CDFwithFriction(qd+1e-9,q_up(0.01,beta),qd,0, 0),CDFwithFriction(qd+1e-9,q_up(0.01,beta),qd,0, 0)],'Color','black','LineStyle','--')
% xticks([2,2.2,2.4,2.6,2.8])
% xticklabels({'log(7.4)','log(9)','log(11)','log(13.5)','log(16.4)'})
ylabel('F(e)')
yticklabels('')
xlabel('')
xticklabels('')
legend('Post regulation','Pre regulation','Location','NorthWest')
% title('\sigma = 0, \alpha = 0.3')
grid off
text([qd-.07 qd+0.004 2.4 2.31 q_up(0.01,beta)+0.005 ], [0.72 0.54 0.8 0.76 0.54], {'$f_0 \Delta e$','$\underline{e}$','$\Delta e$' , '$A=f_0 (\Delta e)^2/2$' , '$\bar{e}$'}, 'Interpreter', 'latex')
hold off;


fig = gcf;
fig.PaperPositionMode = 'manual'; % fig.PaperPositionMode = 'auto' 'auto'
fig.PaperPosition     = [1.3333    3.3125    5.8333    4.3750];
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,strcat(Figures,'\Figure4b'),'-dpdf','-fillpage')

%% PDF
x_pdfs = linspace(log(8),log(16),1000)';
pd = fitdist(apost_sub,'kernel','Bandwidth',0.0075);
y_withz = pdf(pd,x_pdfs);
%%

figure;
hold on
y  = normpdf(x_pdfs,muz-1,sigz);
[~, ix_d] =  min( abs( x_pdfs - log(Abar) ));
[~, ix_u] =  min( abs( x_pdfs - q_up(myk,beta) ));
y(ix_d) =  max(y_withz) ; % To have the upward move
y(ix_d+1) = NaN; % To have the upward move
y( [ix_d+2:ix_u-1] ) = (alpha) * y( [ix_d+2:ix_u-1] ) ;
y( [ix_u] ) = NaN;
h2 = plot(x_pdfs,y,'-','LineWidth',2,'color',[0.8500, 0.3250, 0.0980]);
h3 = plot(x_pdfs, fzero(x_pdfs,0.05),'--','LineWidth',2, 'color',  [0, 0.4470, 0.7410]);
ylim([0 1])
h1 = plot([qd,q_up(0.01,beta);qd,q_up(0.01,beta)],[ylim;ylim]','--k'); 
xticks([2,2.2,2.4,2.6,2.8])
xticklabels({'log(7.4)','log(9)','log(11)','log(13.5)','log(16.4)'})
% line(line_x, line_y, 'Color', 'k')
ylabel('f(e)')
yticklabels('')
xlabel('')
xticklabels('')
legend('Post regulation','Pre regulation','Location','NorthWest')
text([qd+0.004 q_up(0.01,beta)+0.005 ], [0.1  0.1], {'$\underline{e}$' ,'$\bar{e}$'}, 'Interpreter', 'latex')
text(qd+0.004 , .9, {'$B=f_0\Delta e$'}, 'Interpreter', 'latex')
%text(qd+0.1 , .1, {'$f$'}, 'Interpreter', 'latex')
grid off
hold off


fig = gcf;
fig.PaperPositionMode = 'manual'; % fig.PaperPositionMode = 'auto' 'auto'
fig.PaperPosition     = [1.3333    3.3125    5.8333    4.3750];
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,strcat(Figures,'/Figure4a'),'-dpdf','-fillpage')




