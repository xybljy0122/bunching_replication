function [zub_fn] = z_upperbar(b,tau,k,beta, Abar ,options)
%zub_fn Compute the value of z_upper bar from beta, k, 
%   Detailed explanation goes here
if isempty(options)
    options = optimoptions('fsolve','Display','off','OptimalityTolerance',1e-12);
end
e = exp(1);
zlb     =  (Abar*e./b);
zub_fn  =  fsolve( @(x)( 1e6*(Abar/beta) .* (log(x) - log(Abar./b))        ...
                                    - 1e6*b.*x./( beta*exp(1+beta*tau) ) + 1e6*k ),4*zlb, options);

end