function prob = gaussian(x,mu,sig)
y = exp(-(x-mu).^2./(2*sig.^2));
prob = y/sum(y);
end