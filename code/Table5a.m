
clear
clc
close all
rng(0);
%% Set samples


dataFolder = '..\input\';addpath('functions')
samplelist={'res_split_25m','res_split_75m','res_split_700m'};
C=9;


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
cost_list = zeros(2*C,S);
marginal_float_list = zeros(2*C,S);
cost_se_list = zeros(2*C,S);
marg_se_list = zeros(2*C,S);
alpha_list = zeros(2*C,S);
alpha_se_list = zeros(2*C,S);
I_list = zeros(2*C,S); % actual investment
A_list = zeros(2*C,S); % investment opportunity
Area_list = zeros(2*C,S); % bunching area
f_list = zeros(2*C,S); % density at threshold


%% for testing
sub_num=0;
char_num=1;
sample_num=1;
%% estimation of marginal float

for char_num = 1:C
    for sub_num = 0:1
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
            firm_char = cell2mat(rawdata(1:end,4+char_num));
            pubfloat  = [float,post,firm_char];            % put public float and post into one matrix
            
            X  = pubfloat(pubfloat(:,2)==1&pubfloat(:,3)==sub_num,1);               % post float
            X0  = pubfloat(pubfloat(:,2)==0&pubfloat(:,3)==sub_num,1);               % pre float
            
            q_lb =thresholdlist(sample_num);
            x_min = q_lb * below(sample_num);           % same as abottom
            x_max = q_lb * above(sample_num);           % same as atop
            degree=2;
            friction=1;noise=1;fig=0;
            [dx_hat,alpha_hat] = FB(X,X0,q_lb,x_min,x_max,degree,friction,noise,fig);
            
            % calculate the marginal float value based on the estimated bunching range
            j=2*char_num+sub_num-1; %row in the result table
            marginal_float  = q_lb + real(dx_hat);
            marginal_float_list(j,sample_num)=marginal_float;
            alpha_list(j,sample_num) = alpha_hat;
            
            
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
            
            cost_list(j,sample_num)=k;
            I_list(j,sample_num) = I; % actual book assets
            A_list(j,sample_num) = (marginal_float / e); % investment opportunity
            
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
            marg_se_list(j,sample_num)= std(marginal_float_boot); % keep obs with areas>0
            alpha_se_list(j,sample_num)= std(alpha_estimate_boot);
            cost_se_list(j,sample_num)= std(cost_boot);
            
            V_list(j,sample_num)= tobin_q_list(sample_num)*A_list(j,sample_num); % market value of firm
            
            pvcost_list(j,sample_num)=cost_list(j,sample_num)/rE_list(sample_num)/marginal_float_list(j,sample_num)*100; % PV regulatory costs over equity value
            pvcost_se_list(j,sample_num)=cost_se_list(j,sample_num)/rE_list(sample_num)/marginal_float_list(j,sample_num)*100;
            
            lev_chg_list(j,sample_num)=(marginal_float_list(j,sample_num)-thresholdlist(sample_num))/V_list(j,sample_num);% leverage chg
            lev_chg_se_list(j,sample_num)=(marg_se_list(j,sample_num))/V_list(j,sample_num);
            
            inv_chg_list(j,sample_num)=(A_list(j,sample_num)-I_list(j,sample_num))/V_list(j,sample_num);
            inv_chg_se_list(j,sample_num)=(A_list(j,sample_num)-I_list(j,sample_num))/V_list(j,sample_num);
            
            
        end
        
        
        
    end
    
end
%%
close all;
xlswrite('..\output\heterogeneity_local_res.xlsx',[cost_list pvcost_list]);
