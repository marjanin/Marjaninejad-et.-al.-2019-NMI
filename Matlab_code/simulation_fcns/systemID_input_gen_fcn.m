function [t_in,in] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,mode)
%systemID_Tor_gen_fcn Generate torque values for the system ID input         
t_in=linspace(0,T,T*fs);
in=zeros(1,T*fs);
if strcmpi('d',mode)
    for ij=2:T*fs
        pass_rand=rand();
        if pass_rand<pass_chance
            in(ij)=(max_in-min_in)*rand()+min_in;
        else
            in(ij)=in(ij-1);
        end
    end
elseif strcmpi('c',mode)
    for ij=2:T*fs
        pass_rand=rand();
        if pass_rand<pass_chance
            in(ij)=(max_in-min_in)*rand()+min_in;
        else
            in(ij)=in(ij-1);
        end
    end
    %[b,a] = fir1(1000,.01);
    b=ones(1,200)/200;
    a=1;
    in=filtfilt(b,a,in);
    
elseif strcmpi('m',mode)
    [~,in_d] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,'d');
    [t_in,in_c] = systemID_input_gen_fcn(T,fs,pass_chance,max_in,min_in,'c');
    in=[in_d(1:round(end/2)) in_c(round(end/2)+1:end)];
end

