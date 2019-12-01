
import os
import os.path as path
import sys
import utils
import pandas as pd


def prepare_data(protocol_file, data_dir, audio_dir):
    wav_scp = path.join(data_dir, "wav.scp")
    utt2spk = path.join(data_dir, "utt2spk")
    utt2lab = path.join(data_dir, "utt2lab")
    utt2id = path.join(data_dir, "utt2id")
    utils.ensure_dir(data_dir)
    df = pd.read_csv(protocol_file, sep=" ", header=None,
                     names=["spk", "utt", "eid", "sid", "label"])
    df = df.sort_values(by=["utt"])
    with open(wav_scp, "w") as wf, open(utt2spk, "w") as usf, open(utt2id, "w") as uif, open(utt2lab, "w") as ulf:
        for idx, row in df.iterrows():
            spk, utt, eid, sid, label = row.tolist()
            id = 0 if label == "bonafide" else 1
            print(f"{utt} flac -c -d -s {audio_dir}/{utt}.flac |", file=wf)
            print(f"{utt} {spk}", file=usf)
            print(f"{utt} {id}", file=uif)
            print(f"{utt} {label} {sid}", file=ulf)


def prepare_set(access, testset, data_dir, root_dir):
    trl = "trl" if testset in ["eval", "dev"] else "trn"
    protocol_file = f"{root_dir}/{access}/ASVspoof2019_{access}_cm_protocols/ASVspoof2019.{access}.cm.{testset}.{trl}.txt"
    audio_dir = f"{root_dir}/{access}/ASVspoof2019_{access}_{testset}/flac/"
    set_data_dir = path.join(data_dir, f"{access}_{testset}".lower())
    prepare_data(protocol_file, set_data_dir, audio_dir)


def main(arg_vec):
    params = {
        "root_dir": r"/home/boren/data/ASVspoof2019;str",
        "access": r"LA;str",
        "data_dir": r"features/data;str",
        "testset": r"eval;str"
    }
    parser = utils.dict2parser(params)
    args = parser.parse_args(arg_vec)
    print(vars(args))
    prepare_set(args.access, args.testset, args.data_dir, args.root_dir)
    print(f"prepare {args.access}_{args.testset} !")


if __name__ == '__main__':
    if len(sys.argv) > 2:
        arg_vec = sys.argv[1:]
    else:
        params = {
        }
        arg_vec = utils.dict2arg(params)
    main(arg_vec)
