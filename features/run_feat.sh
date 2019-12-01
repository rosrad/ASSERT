#!/bin/bash
# extract fbank, mfcc, logspec, ivector features for:
# ASVspoof2019 LA train, LA dev, LA eval, PA train, PA dev, PA eval

. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc
fbankdir=`pwd`/fbank
specdir=`pwd`/logspec

stage=100

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



if [ $stage -eq 100 ]; then
    # first create spk2utt
    for name in la_train la_dev pa_train pa_dev; do
        utils/utt2spk_to_spk2utt.pl data/${name}/utt2spk > data/${name}/spk2utt
        utils/fix_data_dir.sh data/${name}
        
        # feature extraction
        # mfcc (24), fbank (40), logspec (257)
        # create a copy of data/la_train, la_dev, pa_train, pa_dev for mfcc, fbank & logspec
        
        # mfcc
        utils/copy_data_dir.sh data/${name} data/${name}_mfcc
        steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 40 --cmd "$train_cmd" \
        data/${name}_mfcc exp/make_mfcc $mfccdir
        utils/fix_data_dir.sh  data/${name}_mfcc
        # fbank
        utils/copy_data_dir.sh data/${name} data/${name}_fbank
        steps/make_fbank.sh --fbank-config conf/fbank.conf --nj 40 --cmd "$train_cmd" \
        data/${name}_fbank exp/make_fbank $fbankdir
        utils/fix_data_dir.sh  data/${name}_fbank
        # logspec
        utils/copy_data_dir.sh data/${name} data/${name}_spec
        local/make_spectrogram.sh --spectrogram-config conf/spec.conf --nj 40 --cmd "$train_cmd" \
        data/${name}_spec exp/make_spec $specdir
        utils/fix_data_dir.sh  data/${name}_spec
        
        # apply cm for the extracted features
        # cm is 3-second sliding window
        
        # mfcc
        utils/copy_data_dir.sh data/${name}_mfcc data/${name}_mfcc_cm
        feats="ark:apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 scp:`pwd`/data/${name}_mfcc/feats.scp ark:- |"
        copy-feats "$feats" ark,scp:`pwd`/data/${name}_mfcc_cm/feats.ark,`pwd`/data/${name}_mfcc_cm/feats.scp
        utils/fix_data_dir.sh  data/${name}_mfcc_cm
        
        # fbank
        utils/copy_data_dir.sh data/${name}_fbank data/${name}_fbank_cm
        feats="ark:apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 scp:`pwd`/data/${name}_fbank/feats.scp ark:- |"
        copy-feats "$feats" ark,scp:`pwd`/data/${name}_fbank_cm/feats.ark,`pwd`/data/${name}_fbank_cm/feats.scp
        utils/fix_data_dir.sh  data/${name}_fbank_cm
        
        # logspec
        utils/copy_data_dir.sh data/${name}_spec data/${name}_spec_cm
        feats="ark:apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 scp:`pwd`/data/${name}_spec/feats.scp ark:- |"
        copy-feats "$feats" ark,scp:`pwd`/data/${name}_spec_cm/feats.ark,`pwd`/data/${name}_spec_cm/feats.scp
        utils/fix_data_dir.sh  data/${name}_spec_cm
    done
fi