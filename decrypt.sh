#!/bin/bash
#
# @author       Subir Paul (IT:ES:SE:PE)
#
#

SCRIPT=$0
function usage {
  printf 'Usage: %s -privatekey <receiver private key pem input file> -in <cipher text input file> [-aeskeyiv <encrypted aes+iv input file>] [-out <plain text output file>]\n' $SCRIPT
  exit 1
}

# Reset all variables that might be set
INFILE=
OUTFILE=
PRIVATEKEY=
AESKEYIV=

# Read command line args
while :; do
  case $1 in
    -h|--help) 
      usage 
      ;;
    -in|--in) 
      if [ -n "$2" ]; then
        INFILE=$2
        shift
      else
        printf 'ERROR: "-in" requires a non-empty option argument.\n' >&2
        exit 1
      fi
      ;;
    -aeskeyiv|--aeskeyiv) 
      if [ -n "$2" ]; then
        AESKEYIV=$2
        shift
      else
        printf 'ERROR: "-aeskeyiv" requires a non-empty option argument.\n' >&2
        exit 1
      fi
      ;;
    -privatekey|--privatekey) 
      if [ -n "$2" ]; then
        PRIVATEKEY=$2
        shift
      else
        printf 'ERROR: "-privatekey" requires a non-empty option argument.\n' >&2
        exit 1
      fi
      ;;
    -out|--out) 
      if [ -n "$2" ]; then
        OUTFILE=$2
        shift
      fi
      ;;
    --)  # End of all options.
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *) # Default case: If no more options then break out of the loop.
      break
  esac
  shift
done

if [ -z "$PRIVATEKEY" ]; then
  printf 'missing -privatekey <receiver private key pem input file>\n'
  usage
fi
if [ ! -f $PRIVATEKEY ]; then
  printf 'missing receiver private key pem input file %s\n' $PRIVATEKEY
  exit 1
fi
if [ -z "$INFILE" ]; then
  printf 'missing -in <cipher text input file>\n'
  usage
fi
if [ ! -f $INFILE ]; then
  printf 'missing cipher text input file %s\n' $INFILE
  exit 1
fi
if [ -z "$AESKEYIV" ]; then
  printf 'missing -aeskeyiv <encrypted aes+iv input file>\n'
  usage
fi
if [ ! -f $AESKEYIV ]; then
  printf 'missing encrypted aes+iv input file %s\n' $AESKEYIV
  exit 1
fi
if [ -z "$OUTFILE" ]; then
  OUTFILE=`echo $INFILE.out`
fi

echo "privatekey=$PRIVATEKEY infile=$INFILE aeskeyiv=$AESKEYIV outfile=$OUTFILE" 

# Decrypt encrypted AESKEY+IV using receiver's RSA PKI private key
TMP=`openssl rsautl -decrypt -in $AESKEYIV -inkey $PRIVATEKEY | perl -pe '$_=unpack("H*",$_)'`

# Extract 32 bytes AESKEY and 16 bytes IV
AESKEY2DECRYPT=`echo ${TMP:0:64}`
IV2DECRYPT=`echo ${TMP:64:96}`

# Decrypt payload using D_AESKEY and D_IV
openssl enc -d -aes-256-cbc -in $INFILE -out $OUTFILE -K $AESKEY2DECRYPT -iv $IV2DECRYPT 

# Check if OUTFILE are created
if [ -f $OUTFILE ]; then
  echo "Plain text payload file=$OUTFILE created"
fi

