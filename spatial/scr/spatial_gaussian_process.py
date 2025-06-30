from sklearn.metrics.pairwise import euclidean_distances
# カーネル
def kernel(x, n, sigma=1):
    return np.exp(-1*euclidean_distances(x, x)/(2*sigma**2))

# カーネル回帰
n_knot = X_train.shape[0]
with pm.Model() as model:
    gamma = pm.Cauchy("gamma", alpha=0, beta=1, shape=n_knot)
    eps = pm.HalfCauchy("eps", beta=5)
    mu = pm.math.dot(gamma, kernel(X_train, n_knot))
    y_pred = pm.Normal("y_pred", mu=mu, sigma=eps, observed=y_train)
    trace = pm.sample(1000, chains=2, cores=1)

az.plot_trace(trace, var_names=["gamma", "eps"])
az.plot_autocorr(trace, var_names=["gamma", "eps"], combined=True)
az.summary(trace, var_names=["gamma", "eps"])
