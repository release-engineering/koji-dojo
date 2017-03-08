Name:           test-package-fail
Version:        1
Release:        1%{?dist}
Summary:        Testing package fail
                                                                                                                                                                                                                                             
Group:          Applications/System                                                                                                                                                                                                          
License:        GPLv2                                                                                                                                                                                                                        
URL:            http://nonexistent                                                                                                                                                                                                           
                                                                                                                                                                                                                                             
%description                                                                                                                                                                                                                                 
Test rpm fail

%prep
#%setup -q
a.sh

%build


%install


%files
%doc                                                                                                                                                                                                                               
                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                             
%changelog                                                                                                                                                                                                                                   
* Tue Mar 07 2017 Jana Cupova <jcupova at redhat.com>                                                                                                                                                                                     
- test rpm fail
