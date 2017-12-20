#!/bin/bash
#
# @author       Subir Paul (IT:ES:SE:PE)
#
#

SCRIPT=$0
function usage {
  printf 'Usage: %s -pubkey <receiver public key pem input file> -in <plain text input file> [-aeskeyiv <encrypted aeskey+iv output file>] [-out <cipher text output file>\n' $SCRIPT
  exit 1
}

if [ $# -le 1 ]; then 
  usage
fi

# Reset all variables that might be set
INFILE=
OUTFILE=
PUBKEY=
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
    -pubkey|--pubkey) 
      if [ -n "$2" ]; then
        PUBKEY=$2
        shift
      else
        printf 'ERROR: "-pubkey" requires a non-empty option argument.\n' >&2
        exit 1
      fi
      ;;
    -aeskeyiv|--aeskeyiv) 
      if [ -n "$2" ]; then
        AESKEYIV=$2
        shift
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

if [ -z "$PUBKEY" ]; then
  printf 'missing -pubkey <receiver public key pem input file>\n'
  usage
fi
if [ ! -f $PUBKEY ]; then
  printf 'missing receiver public key input file %s\n' $PUBKEY
  exit 1
fi
if [ -z "$INFILE" ]; then
  printf 'missing -in <plain text input file>\n'
  usage
fi
if [ ! -f $INFILE ]; then
  printf 'missing plain text input file %s\n' $INFILE
  exit 1
fi
if [ -z "$OUTFILE" ]; then
  OUTFILE=`echo $INFILE.out`
fi
if [ -z "$AESKEYIV" ]; then
  AESKEYIV=`echo $INFILE.aeskeyiv`
fi

echo "pubkey=$PUBKEY infile=$INFILE aeskeyiv=$AESKEYIV outfile=$OUTFILE" 

# Create 32 bytes random AES key
TMP=`openssl rand 32 -hex`
AESKEY=`echo ${TMP:0:64}`

# Create 16 bytes random Initialization Vector (IV)
TMP=`openssl rand 16 -hex`
IV=`echo ${TMP:0:32}`

# Encrypt payload with key AESKEY and iv IV
openssl enc -e -aes-256-cbc -in $INFILE -out $OUTFILE -K $AESKEY -iv $IV

# Concatenate 32 bytes AESKEY and 16 bytes IV
TMP=`echo -n $AESKEY$IV`

# Convert AESKEY+IV hex to binary
AESKEYIVBIN=`echo $AESKEYIV.bin`
echo -n $TMP|perl -pe '$_=pack("H*",$_)' > $AESKEYIVBIN

# Encrypt aeskey_iv.bin with receiver's RSA PKI public key
openssl rsautl -encrypt -out $AESKEYIV -pubin -inkey $PUBKEY -in $AESKEYIVBIN

#delete AESKEYIVBIN
if [ -f $AESKEYIVBIN ]; then
  rm -f $AESKEYIVBIN
fi

# Check if OUTFILE and AESKEYIV are created
if [ -f $OUTFILE ] && [ -f $AESKEYIV ]; then
  echo "Cipher text payload file=$OUTFILE and aes key file=$AESKEYIV created"
fi
read -p "Press enter to continue"
