home: {{ salt.sdb.get('sdb://osenv/HOME') }}
clone_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/gl' }}
package_dir: {{ salt.sdb.get('sdb://osenv/HOME') + '/z/dy' }}
