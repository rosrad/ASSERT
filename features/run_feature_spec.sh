#!/bin/bash
# extract fbank, mfcc, logspec, ivector features for:
# ASVspoof2019 LA train, LA dev, LA eval, PA train, PA dev, PA eval

. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
fbankdir=`pwd`/fbank
specdir=`pwd`/logspec
vadir=`pwd`/mfcc

stage=0

if [ $stage -eq 0 ]; then
    # first create spk2utt
    for name in la_eval; do
        utils/utt2spk_to_spk2utt.pl data/${name}/utt2spk > data/${name}/spk2utt
        utils/fix_data_dir.sh data/${name}
        
        # feature extraction
        # logspec (257)
        # create a copy of data/la_eval, pa_eval, for logspec
        
        # logspec
        utils/copy_data_dir.sh data/${name} data/${name}_spec
        local/make_spectrogram.sh --spectrogram-config conf/spec.conf --nj 40 --cmd "$train_cmd" \
        data/${name}_spec exp/make_spec $specdir
        utils/fix_data_dir.sh  data/${name}_spec
        
        # apply cm for the extracted features
        # cm is 3-second sliding window
        
        # logspec
        utils/copy_data_dir.sh data/${name}_spec data/${name}_spec_cm
        feats="ark:apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 scp:`pwd`/data/${name}_spec/feats.scp ark:- |"
        copy-feats "$feats" ark,scp:`pwd`/data/${name}_spec_cm/feats.ark,`pwd`/data/${name}_spec_cm/feats.scp
        utils/fix_data_dir.sh  data/${name}_spec_cm
    done
fi

