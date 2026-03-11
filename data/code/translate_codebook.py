import pandas as pd
import re
import os


def main(survey, PATH, folder, sheet_name='Qualtrics'):
    """ Main function to execute.

    Notes
    -----
    Automatically generate Stata cleaning code from codebook.
    """
    codebook = pd.DataFrame(pd.read_excel(dname+PATH,sheet_name = sheet_name,engine='openpyxl'))
    print(codebook.columns)
    codebook.drop(codebook.loc[codebook[survey] != 1].index, inplace=True)
    mypath = dname+'/temp'+folder
    if not os.path.isdir(mypath):
        os.makedirs(mypath)

    create_rename_code(codebook,    do_path = dname+'/temp'+folder+'/rename_code.do')
    create_tostring_code(codebook,  do_path = dname+'/temp'+folder+'/tostring_code.do')
    create_sdecode_code(codebook,   do_path = dname+'/temp'+folder+'/sdecode_code.do')
    create_replace_code(codebook,   do_path = dname+'/temp'+folder+'/replace_code.do')
    create_destring_code(codebook,  do_path = dname+'/temp'+folder+'/destring_code.do')
    create_label_code(codebook,     do_path = dname+'/temp'+folder+'/label_code.do')
    create_label_var_code(codebook, do_path = dname+'/temp'+folder+'/label_var_code.do')
    
def create_rename_code(codebook, do_path):
    """ Create rename code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates Stata code renaming variables from column `Original name` to 
      column `Variable name`.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook = (codebook.dropna(subset = ['Variable name'])
                        .set_index(['Variable name'])
                        .to_dict()
               )
    codebook = codebook['Original name']

    print(codebook)
    
    # Generate code
    rename = 'rename %s %s'
    rename_code = [rename % (v, k) for k, v in codebook.items()]
    rename_code = '\n'.join(rename_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(rename_code)
        
def create_tostring_code(codebook, do_path):
    """ Create tostring code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates Stata code converting variables in column `Variable name` 
      to string.
    - The `capture` prefix is used as some variables are already in string
      format in the raw data or are numeric with value labels.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook = codebook.dropna(subset = ['Variable name', 'Values'])
    
    # Process values
    codebook['Values'] = codebook['Values'].str.split(" = ")
    codebook['Values'] = codebook['Values'].apply(lambda x: ['"%s"' % x[0], '"%s"' % x[1]])
    
    # Generate code
    tostring = 'capture tostring %s, replace'
    
    tostring_code = list(codebook['Variable name'])
    tostring_code = [tostring % var for var in tostring_code]
    tostring_code = '\n'.join(tostring_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(tostring_code)
                
def create_sdecode_code(codebook, do_path):
    """ Create sdecode code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates Stata code decoding variables in column `Variable name` 
      to string.
    - Numeric variables with value labels cannot be converted to string in
      Stata; they must be decoded.
    - `sdecode` is an enhanced version of `decode`. 
      See [here](http://fmwww.bc.edu/RePEc/bocode/s/sdecode.html).
    - The `capture` prefix is used as some variables are already in string
      format in the raw data.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook = codebook.dropna(subset = ['Variable name', 'Values'])
    
    # Process values
    codebook['Values'] = codebook['Values'].str.split(" = ")
    codebook['Values'] = codebook['Values'].apply(lambda x: ['"%s"' % x[0], '"%s"' % x[1]])
    
    # Generate code
    sdecode = 'capture sdecode %s, replace'
    
    sdecode_code = list(codebook['Variable name'])
    sdecode_code = [sdecode % var for var in sdecode_code]
    sdecode_code = '\n'.join(sdecode_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(sdecode_code)
        
def create_replace_code(codebook, do_path):
    """ Create replace code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates code recoding variables in column `Variable name` according to
      the mapping in column `Values`.
    - The right-hand side of `Values` is the value to be replaced. 
      The left-hand side of `Values` is the value to use for replacement. 
      For example, `1 = Yes` will be parsed as replace `Yes` with `1`.
    - All text in brackets are ignored. For example, `1 = 1 [Yes]` will be 
      parsed as replace `1` with `1`.
    - `All other options` includes all non-missing, non-binary values. For
      example, `0 = All other options` will be parsed as replace all values that
      are not `0`, `1`, or empty as `0`.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook[['Variable name']] = codebook[['Variable name']].fillna(method = 'ffill')
    codebook = codebook.dropna(subset = ['Values'])
    
    # Process values
    codebook['Values'] = codebook['Values'].str.split(" = ")
    codebook['Values'] = codebook['Values'].apply(lambda x: ['"%s"' % x[0], '"%s"' % x[1]])
    
    # Generate code
    replace_code = []
    
    for index, row in codebook.iterrows():
        var = row['Variable name']
        values = row['Values']

        # Remove bracketed comments
        if re.search(' /[.*/]', values[1]):
            values[1] = re.sub(' /[.*/]', '', values[1])
        
        # Determine replace code
        if re.match('"All other options"', values[1]):
            replace = 'replace %s = %s if !inlist(%s, "0", "1", "")'
            replace_code.append(replace % (var, values[0], var))
        else:
            replace = 'replace %s = %s if %s == %s'        
            replace_code.append(replace % (var, values[0], var, values[1]))

    replace_code = '\n'.join(replace_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(replace_code)
        
def create_destring_code(codebook, do_path):
    """ Create tostring code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates Stata code converting variables in column `Variable name` 
      to numeric.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook = codebook.dropna(subset = ['Variable name', 'Values'])
    
    # # Process values
    # codebook['Values'] = codebook['Values'].str.split(" = ")
    # codebook['Values'] = codebook['Values'].apply(lambda x: ['"%s"' % x[0], '"%s"' % x[1]])
    
    # Generate code
    destring = 'destring %s, replace'
    
    destring_code = list(codebook['Variable name'])
    destring_code = [destring % var for var in destring_code]
    destring_code = '\n'.join(destring_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(destring_code)

def create_label_code(codebook, do_path):
    """ Create variable label code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates Stata code variable labeling variables in column `Variable name` 
      with column `Variable label`.
    """

    # Process codebook
    codebook = codebook.copy()
    codebook = (codebook.dropna(subset = ['Variable name'])
                        .set_index(['Variable name'])
                        .to_dict()
               )
    codebook = codebook['Variable label']

    # Generate code  
    label = 'label var %s "%s"'
    label_code = [label % (k, str(v).strip()) for k, v in codebook.items()]
    label_code = '\n'.join(label_code) + '\n'
    
    with open(do_path, 'w') as f:
        f.write(label_code)
        
def create_label_var_code(codebook, do_path):
    """ Create value label code.
    
    Parameters
    ----------
    codebook : pd.DataFrame
        Codebook to generate Stata code from.
    do_path : str
        Do-file path to write Stata code.

    Notes
    -----
    - Generates code value labeling variables in column `Variable name` 
      according to the mapping in column `Values`.
    - The left-hand side of `Values` is the actual value of the variable. 
      The right-hand side of `Values` is the value to use for value labeling. 
      For example, `1 = Yes` will be parsed as label `1` with `Yes`.
    - All text in brackets are ignored. For example, `1 = 1 [Yes]` will be 
      parsed as label `1` with `1`.
    """

    # Process codebook    
    codebook = codebook.copy()
    codebook[['Variable name']] = codebook[['Variable name']].fillna(method = 'ffill')
    codebook = codebook.dropna(subset = ['Values'])
    
    # Process values
    codebook['Values'] = codebook['Values'].apply(lambda x: re.sub(' /[.*/]', '', x))
    codebook['Values'] = codebook['Values'].str.split(" = ")
    codebook['Values'] = codebook['Values'].apply(lambda x: [x[0], '"%s"' % x[1]])
    codebook = codebook.groupby(['Variable name']).agg({'Values': sum})
    codebook = codebook.to_dict()['Values']

    # Generate code
    define = 'label define %s %s, replace'
    define_code = [define % (k, ' '.join(v)) for k, v in codebook.items()]
    define_code = '\n'.join(define_code)
    
    values = 'label values %s %s'
    values_code = [values % (k, k) for k, v in codebook.items()]
    values_code = '\n'.join(values_code) + '\n'
    
    # Save code
    with open(do_path, 'w') as f:
        f.write(define_code + '\n\n' + values_code)

# Change directory so file can be ran both directly and from make
current = os.getcwd()
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

# Part 1: Qualtrics tab (existing behavior)
main(survey = 'Experiment1', PATH = '/raw/codebook_sender_survey_zuerich_insta_experiment.xlsx', folder = '/sender_survey_zuerich_insta_experiment', sheet_name = 'Qualtrics')

# Part 2: NLP_Measurements tab (new)
main(survey = 'Experiment1', PATH = '/raw/codebook_sender_survey_zuerich_insta_experiment.xlsx', folder = '/gpt_pangram_measures', sheet_name = 'NLP_Measurements')

os.chdir(current)
