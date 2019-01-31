function [KE, PE] = dbpend_energy(t,z,m1, m2, I1, I2, l, a, g)

q1 = z(1);                          
u1 = z(2);                          
q2 = z(3);                         
u2 = z(4);  

KE = 1/2*m1*u1^2*a^2+1/2*m2*u1^2*l^2+m2*u1*l*u2*a*cos(-q1+q2)+1/2*m2*u2^2*a^2+1/2*I1*u1^2+1/2*I2*u2^2;
 
PE = -a*m1*g*cos(q1)-m2*g*(l*cos(q1)+a*cos(q2));