function [dist] = mahal(mu, sig, pt)

if size(sig,1) == 1
	sig = eye(size(mu,1)) * sig;
end

dist = sqrt( (mu - pt)' * inv(sig) * (mu - pt) );
