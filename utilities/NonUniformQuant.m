clc; clear all;

%companded_sgl(i)=A*log(1+u*(Sampled_sgl(i)/A))/log(1+u);
%0 no companding 255 good companding

A=1;
N = 1000;
Sampled_Signal = rand(1,N); 
subplot(2,2,1);
plot(Sampled_Signal);
title("Original Signal");

%MU-law companding
u=255; %compression constant
for i=1:N
 companded_signal(i)=sign(Sampled_Signal(i))*(A*log(1+u*(abs(Sampled_Signal(i))/A))/log(1+u));
end
subplot(2,2,2);
plot(companded_signal);
title("Companded Signal");

signal_power=(sum(companded_signal)^2)/length(companded_signal);
for j=1:100 %Number of levels
  levels=j;
  N = length(companded_signal);
  signalPower = ((sum(companded_signal.^2))/N);
  mx = max(companded_signal);
  mn = min(companded_signal);
  stepSize = (mx-mn)/levels;
  error = 0;
  steps = zeros(1,levels);
  for i = 1:length(steps)
      steps(i) = mn + i*stepSize;
  end
  for i=1:N
     for j = 2:levels     
        if (companded_signal(i) >= steps(j-1) && companded_signal(i) <= steps(j))
            diff = companded_signal(i) - (steps(j-1) + steps(j))/2;
           error = error + diff^2;
        end
     end
  end
  
  noisePower = error/N;
  SNQR(j) = signalPower/noisePower;
end
 
subplot(2,2,3);
plot(SNQR);
title("SNQR vs Levels");
xlabel("levels");
ylabel("SNQR");