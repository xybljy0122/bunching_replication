function F = CDFwithFriction(a,qu,qd,sig,alpha)

global muz sigz
Phi  = @(z) normcdf(z);
phi  = @(z) normpdf(z);

G      = @(x) Phi((1+x-muz)/sigz);

    if sig ~=0
         F1     =  integral(@(u) G(a-sig*u)*phi(u), - 100, max(-100,(a-qu)/sig), 'ArrayValued',true);
         F2     = (1-alpha) * (G(qu) * (Phi((a-qd)/sig) - Phi((a-qu)/sig))) + alpha * integral(@(u) G(a-sig*u)*phi(u), max(-100,(a-qu)/sig), max(-100,(a-qd)/sig), 'ArrayValued',true) ;
         F3     = integral(@(u) G(a-sig*u)*phi(u), max((a-qd)/sig,-100), 100, 'ArrayValued',true);

    else
         F1     = G(a) * (a >= qu);
         F2     = (a >= qd) *(a<qu)* ((1-alpha) * G(qu) + alpha * G(a));
         F3     = G(a) * (a<qd);

    end
       
    F = F1 + F2 + F3;
end
