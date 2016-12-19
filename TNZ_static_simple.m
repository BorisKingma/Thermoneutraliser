function [data] = TNZ_static(Ta,Ts,v_air, Rh, A, Icl, M, TcMax, TcMin, IbMax, IbMin, alpha, W )
n = length(Ta);
Ts_c = zeros(n,n);
alphas = zeros(n,n);
calculateAlpha = 0;
if( alpha > 0 )
    Mmax = (1-alpha) * max(M);
    Mmin = (1-alpha) * min(M);
    
    TsMin = TcMin - Mmax*IbMax/A;
    TsMax = TcMax - Mmin*IbMin/A;
    
    
    Ts_r = TsMax - TsMin;
    Ts_rc = (IbMax-IbMin)/Ts_r;
else
    calculateAlpha = 1;
    Mtot = nanmean(M);
end

for i=1:n
    for j=1:n %1st dim = Tclo and 2nd dim is Tair
        
        if( calculateAlpha ) %calculate alpha according to Fanger
            Pa_res = 0.001 * vapourpressure(Ta(j), Rh);
            Cres = 0.0014 * Mtot * ( 34 - Ta(j) );
            Eres = 0.0173 * Mtot * ( 5.87 - Pa_res );
            Qrsp = Cres + Eres;
            alpha = Qrsp / Mtot;
           
            Mmax = (1-alpha) * max(M);
            Mmin = (1-alpha) * min(M);
            
            TsMin = TcMin - Mmax*IbMax/A;
            TsMax = TcMax - Mmin*IbMin/A;
            
            Ts_r = TsMax - TsMin;
            Ts_rc = (IbMax-IbMin)/Ts_r;
        end
        alphas(i,j) = alpha;
        
        T = Ta(j)+273.15;
        a1 = 0.61*(T/298)^3; %radiative
        a2 = 0.19*sqrt(v_air*100)*(298/T); %convective
        Ia = 0.155/(a1+a2); %m2K/W
        
        %gagge model for evaporation
        Pa = 0.00750061683 * vapourpressure(Ta(j), Rh); %pascal to mmHg
        Psat_ts = 0.00750061683 * vapourpressure(Ts(i), 1); %pascal to mmHg
        CTC = 1/Ia; %W/m2K
        CHR = a1/0.155; %W/m2K
        HC = (CTC-CHR); %W/m2K
        
        lewis = 2.2;
        CLO = Icl/0.155; %clo
        Fpcl = 1/(1+0.143*(CTC-CHR)*CLO);
        
        Ts_c(i,j) =Ts(i);
        Ibf =  Ts_rc*(Ts_c(i,j)-TsMin);
        Ibody = min( IbMax, max( (IbMax-Ibf), IbMin ));
        
        Emax = lewis*HC*(Psat_ts - Pa)*Fpcl;
        Qe = W*Emax; %W/m2
        Tb(i,j) = (Ibody)*((Ts_c(i,j)-Ta(j))/(Icl+Ia) + Qe) + Ts_c(i,j);
        Qsk_cl(i,j) = (A / (Icl+Ia) ) * ( Ts_c(i,j) - Ta(j) ) + A*Qe;
    end
end

Q = Qsk_cl; %heat loss;

Tb(Tb<TcMin ) = NaN;
Tb(Tb>TcMax ) = NaN;

Tcit = Tb;
Tcit(Q < Mmax ) = NaN;

Tsw = Tb;
Tsw(Q > Mmin ) = NaN;

Tb( Q < Mmin) = NaN;
Tb( Q > Mmax ) = NaN;

data.Ta = Ta;
data.Ts = Ts;
data.Tcit = Tcit;
data.Tsw = Tsw;
data.Tb = Tb;
data.Q = Q;
data.alphas = alphas;
end