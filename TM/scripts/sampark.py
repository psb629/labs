def greek(letter):
    switcher = {
        'alpha':'\u03B1',   'ALPHA':'\u0391',
        'beta':'\u03B2',    'BETA':'\u0392',
        'gamma':'\u03B3',   'GAMMA':'\u0393',
        'delta':'\u03B4',   'DELTA':'\u0394',
        'epilson':'\u03B5', 'EPSILON':'\u0395',
        'zeta':'\u03B6',    'ZETA':'\u0396',
        'eta':'\u03B7',     'ETA':'\u0397',
        'theta':'\u03B8',   'THETA':'\u0398',
        'iota':'\u03B9',    'IOTA':'\u0399',
        'kappa':'\u03BA',   'KAPPA':'\u039A',
        'lamda':'\u03BB',   'LAMDA':'\u039B',
        'mu':'\u03BC',      'MU':'\u039C',
        'nu':'\u03BD',      'NU':'\u039D',
        'xi':'\u03BE',      'XI':'\u039E',
        'omicron':'\u03BF', 'OMICRON':'\u039F',
        'pi':'\u03C0',      'PI':'\u03A0',
        'rho':'\u03C1',     'RHO':'\u03A1',
        'sigma':'\u03C3',   'SIGMA':'\u03A3',
        'tau':'\u03C4',     'TAU':'\u03A4',
        'phi':'\u03C6',     'PHI':'\u03A6',
        'chi':'\u03C7',     'CHI':'\u03A7',
        'psi':'\u03C8',     'PSI':'\u03A8',
        'omega':'\u03C9',   'OMEGA':'\u03A9'
    }
    return switcher.get(letter, "Error : Invalid letter")