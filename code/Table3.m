
clear
clc
close all
rng(0);
%% Set samples

dataFolder = '..\input\';addpath('functions')
samplelist={'estimationsample_25m','estimationsample_75m','estimationsample_700m'};



S=size(samplelist,2);


% Set parameters to translate marginal float to regulatory costs k
thresholdlist=[25,75,700];
below =[.92;.9;.9];
above =[1.12;1.4;1.2];
%% parameter values
r_list       = [0.115;0.093;0.0485];
tobin_q_list = [2.72;1.68;3.570];
e_list       = [2.00;0.88;1.572];
beta_list    = [4.637;5.130;6.192];
rE_list    = [0.067;0.076;0.090];

%% Initialize vectors to collect results
cost_list = zeros(S,1);
marginal_float_list = zeros(S,1);
cost_se_list = zeros(S,1);
marg_se_list = zeros(S,1);
alpha_list = zeros(S,1);
alpha_se_list = zeros(S,1);
I_list = zeros(S,1); % actual investment
A_list = zeros(S,1); % investment opportunity
Area_list = zeros(S,1); % bunching area
f_list = zeros(S,1); % density at threshold
nobs_list = zeros(S,1); % number of observations


%% estimation of marginal float

for sample_num = 1:S
    dataFile=strcat(samplelist{sample_num},'.xlsx');
    threshold=thresholdlist(sample_num);
    % set parameters
    beta    = beta_list(sample_num);
    r       = r_list(sample_num);
    tobin_q = tobin_q_list(sample_num);
    e      =  e_list(sample_num);
    
    format short g
    [numdata,txtdata,rawdata] = xlsread([dataFolder dataFile]);
    
    float = cell2mat(rawdata(1:end,3));  % public float
    post  = cell2mat(rawdata(1:end,4));  % post variable
    pubfloat  = [float,post];            % put public float and post into one matrix
    
    X  = pubfloat(pubfloat(:,2)==1,1);               % post float
    X0  = pubfloat(pubfloat(:,2)==0,1);               % pre float
    
    q_lb =thresholdlist(sample_num);
    x_min = q_lb * below(sample_num);           % same as abottom
    x_max = q_lb * above(sample_num);           % same as atop
    degree=2;
    friction=1;noise=1;fig=0;
    
    [dx_hat,alpha_hat] = FB(X,X0,q_lb,x_min,x_max,degree,friction,noise,fig);
    nobs_list(sample_num) = size(X,1)+size(X0,1); % sample size
    
    % calculate the marginal float value based on the estimated bunching range
    marginal_float  = q_lb + dx_hat;
    marginal_float_list(sample_num)=marginal_float;
    alpha_list(sample_num) = alpha_hat;
    
    
    % check if the marginal capital structure distortion is > 1
    marginal_cap_structure_distortion = beta * r * (e - (q_lb / (marginal_float / e)));
    if marginal_cap_structure_distortion<1
        I = marginal_float / e; % optimal investment when marginal capital structure distortion <1
    else
        % solve for optimal investment for marginal firm in presence of the regulatory costs
        syms('x');
        eqn     = beta * r * tobin_q* (marginal_float / e) * (e - (q_lb / x)) * (q_lb / (x^2)) == 1;
        S       =double(solve(eqn)); % convert to number
        S = S(imag(S)==0); % Save only the real roots
        I_q1    = max(S,0); % estimated investment that minimize the loss in Values of bunching marginal firm
        I_q2    = marginal_float / e; % estimated undistorted book assets for marginal bunching firm
        I       = min(I_q1,I_q2); % take the lower one as our optimal investment for marginal firm in presence of the regulatory costs
    end
    % estimated regulatory costs k
    k = 0.5 * beta * r^2 * tobin_q * (marginal_float / e) * e^2 * (1 - q_lb / marginal_float)^2 ;
    
    cost_list(sample_num)=k;
    I_list(sample_num) = I; % actual book assets
    A_list(sample_num) = (marginal_float / e); % investment opportunity
    
    %% bootstrap standard error calculations
    %  generate N samples from the current post float Values
    N_boot = 100;
    marginal_float_boot= zeros(N_boot,1);
    alpha_estimate_boot = zeros(N_boot,1);
    cost_boot    = zeros(N_boot,1);
    
    fig=0;
    rng(12345); % set seed
    for i = 1:N_boot
        X_boot = datasample(X, length(X));
        
        [dx_hat,alpha_hat] = FB(X_boot,X0,q_lb,x_min,x_max,degree,friction,noise,fig);
        
        
        marginal_float=q_lb + dx_hat;
        % calculate the marginal float value based on the estimated bunching range
        marginal_float_boot(i) = marginal_float;
        alpha_estimate_boot(i) = alpha_hat;
        % check if the marginal capital structure distortion is > 1
        marginal_cap_structure_distortion = beta * r * (e - (q_lb / (marginal_float / e)));
        if marginal_cap_structure_distortion<1
            I = marginal_float / e; % optimal investment when marginal capital structure distortion <1
        else
        end
        % estimated regulatory costs k
        k = 0.5 * beta * r^2 * tobin_q * (marginal_float / e) * e^2 * (1 - q_lb / marginal_float)^2 ;
        
        cost_boot(i)=k;
    end
    % calculate the bootstrap standard error, which is the standard deviation of "marginal_float"
    marg_se_list(sample_num)= std(marginal_float_boot); % keep obs with areas>0
    alpha_se_list(sample_num)= std(alpha_estimate_boot);
    cost_se_list(sample_num)= std(cost_boot);
    
    marginal_float_boot_list(:,sample_num)=marginal_float_boot;
    cost_boot_list(:,sample_num)=cost_boot;
    
end



%% write Latex code to produce Table 1


marginal_float_list=real(marginal_float_list);


for i=1:sample_num
    V_list(i)= tobin_q_list(i)*A_list(i); % market value of firm
    
    pvcost_list(i)=cost_list(i)/rE_list(i)/marginal_float_list(i)*100; % PV regulatory costs over equity value
    pvcost_se_list(i)=cost_se_list(i)/rE_list(i)/marginal_float_list(i)*100;
    
    lev_chg_list(i)=(marginal_float_list(i)-thresholdlist(i))/V_list(i);% leverage chg
    lev_chg_se_list(i)=(marg_se_list(i))/V_list(i);
    
    inv_chg_list(i)=(A_list(i)-I_list(i))/V_list(i);
    inv_chg_se_list(i)=(A_list(i)-I_list(i))/V_list(i);
end




%% Estimation result
filename = strcat('../output/Table3','.tex');
FID = fopen(filename, 'w'); % initialize tex document and pointer

fprintf(FID, '\\begin{centering}\\begin{tabular*}{\\linewidth}{@{\\extracolsep{\\fill}}lcccc@{}}\\toprule \n');
fprintf(FID, 'Threshold&');
fprintf(FID, ' \\$%5.0f mil   & \\$%5.0f mil   & \\$%5.0f mil    \\\\   \n',thresholdlist);
fprintf(FID, ' & (1)   & (2)   & (3)    \\\\  \\midrule \n');
fprintf(FID, '  \\\\ \n');


fprintf(FID, ' & & \\textit{Panel A. Estimates} & & \\\\  \\midrule \n');
%fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Marginal firm ($\\overline{e}$) (\\$m)&');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',marginal_float_list);
fprintf(FID, '&');
fprintf(FID, '[%5.3f]   &[%5.3f]     &[%5.3f]    \\\\ \n',marg_se_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Regulatory costs (k)  (\\$m)&');
fprintf(FID, '%5.3f   &%5.3f    &%5.3f     \\\\ \n',cost_list);
fprintf(FID, '&');
fprintf(FID, '[%5.3f]   &[%5.3f]      &[%5.3f]    \\\\ \n',cost_se_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'PV(regulatory costs)/Public float ($\\%%$) &');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',pvcost_list);
fprintf(FID, '&');
fprintf(FID, '[%5.3f]   &[%5.3f]     &[%5.3f]    \\\\ \n',pvcost_se_list);
fprintf(FID, '  \\\\ \n');


fprintf(FID, 'Non-bunching fraction ($\\alpha$)&');
fprintf(FID, '%5.3f   &%5.3f      &%5.3f     \\\\ \n',alpha_list);
fprintf(FID, '&');
fprintf(FID, '[%5.3f]   &[%5.3f]     &[%5.3f]    \\\\ \n',alpha_se_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, '$\\Delta$ Leverage  &');
fprintf(FID, '%5.3f   &%5.3f    &%5.3f     \\\\ \n',lev_chg_list);
fprintf(FID, '&');
fprintf(FID, '[%5.3f]   &[%5.3f]    &[%5.3f]    \\\\ \n',lev_chg_se_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, ' & & \\textit{Panel B. Parameters} & & \\\\  \\midrule \n');
%fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Public float/Assets ($\\eta$)&');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',e_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Tobin Q ($q$)&');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',tobin_q_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Interest rate ($r$)&');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',r_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Marginal cost of debt ($\\beta$) &');
fprintf(FID, '%5.3f   &%5.3f     &%5.3f     \\\\ \n',beta_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, ' & & \\textit{Panel C. Sample} & & \\\\  \\midrule \n');
%fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Bunching sample&');
fprintf(FID, '1994-2007  &2003-2007    &2012-2018     \\\\ \n');
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Non-bunching sample&');
fprintf(FID, '2009-2018  &1994-2002   &1997-2011     \\\\ \n');
fprintf(FID, '  \\\\ \n');


fprintf(FID, 'Identified regulation&');
fprintf(FID, 'Scaled  &SOX 404+       &EGC    \\\\ \n');
fprintf(FID, '&');
fprintf(FID, 'disclosure              &filing delay         &benefits     \\\\ \n');
fprintf(FID, '  \\\\ \n');

fprintf(FID, 'Sample size &');
fprintf(FID, '%5.0f   &%5.0f     &%5.0f     \\\\ \n',nobs_list);
fprintf(FID, '  \\\\ \n');

fprintf(FID, '\\bottomrule \\end{tabular*} \\par\\end{centering}\n');
fclose(FID); % close tex file

csvwrite('../output/marginal_float_boot.csv',[marginal_float_boot_list cost_boot_list])
