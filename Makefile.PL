use inc::Module::Install;

RTx        'RT-Action-SendReminder';
license    'gpl_2';
repository 'https://github.com/catalyst-cloud/RT-Action-SendReminder';

requires_rt '4.4.0';

sign;
WriteAll;
